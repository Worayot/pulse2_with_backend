import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint("BACKGROUND TAP: ${response.id}");
}

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isRestoring = false;

  // Bumped to v5 to ensure fresh system settings for sound support
  final String alarmChannel = 'alarm_channel_v5';

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [],
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.id}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final ios =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("iOS permission granted = $iosGranted");

    // 5. Android channel setup (safe to call every launch)
    final android =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'alarm_channel_v5',
        'Alarms',
        description: 'Alarm notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('alarm'),
      ),
    );

    // 6. Android permissions
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final canExact = await android?.canScheduleExactNotifications();
    debugPrint("canScheduleExactNotifications = $canExact");

    // 7. Restore saved alarms
    await restoreAlarms();

    _isInitialized = true;

    debugPrint("AlarmService initialized successfully");
  }

  Future<bool> ensureAlarmPermission() async {
    final platform =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final iosPlatform =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosPlatform != null) {
      return true;
    }

    if (platform != null) {
      final notifGranted = await platform.requestNotificationsPermission();
      if (notifGranted != true) return false;

      final exactGranted = await platform.requestExactAlarmsPermission();
      return exactGranted ?? false;
    }

    return false;
  }

  Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    String? patientID,
    String sound = 'alarm', // Supports dynamic sound selection
  }) async {
    debugPrint("setAlarm called for sound: $sound");

    if (!_isRestoring) {
      final allowed = await ensureAlarmPermission();
      if (!allowed) {
        debugPrint("Alarm NOT scheduled: permission denied");
        return;
      }
    }

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime.from(dateTime, tz.local);

    if (scheduled.isBefore(now)) {
      debugPrint("Scheduled time is in the past → pushing to tomorrow");
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Scheduling the actual Alarm
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannel,
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          // Uses the sound passed in the parameter
          sound: RawResourceAndroidNotificationSound(sound),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: '$sound.mp3',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await _notifications.show(
      id: id + 999999,
      title: 'Alarm Scheduled',
      body: 'Your alarm is set for ${scheduled.toString()}',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannel,
          'Confirmation',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint("Alarm scheduled successfully: ID=$id with sound=$sound");
    await saveAlarmToPrefs(id, dateTime, title, body, sound, patientID);
  }

  Future<void> stopAlarm(int alarmId) async {
    // FIXED: Named parameter 'id' required for cancel
    await _notifications.cancel(id: alarmId);
    await removeAlarmFromPrefs(alarmId);
    debugPrint('Alarm $alarmId cancelled');
  }

  Future<void> stopAllAlarms() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_alarms');
    debugPrint('All alarms cancelled');
  }

  Future<void> saveAlarmToPrefs(
    int id,
    DateTime dateTime,
    String title,
    String body,
    String sound,
    String? patientID,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.removeWhere((item) => jsonDecode(item)['id'] == id);

    savedAlarms.add(
      jsonEncode({
        'id': id,
        'patientId': patientID,
        'dateTime': dateTime.toIso8601String(),
        'title': title,
        'body': body,
        'sound': sound,
      }),
    );
    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  Future<void> removeAlarmFromPrefs(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];
    savedAlarms.removeWhere((item) => jsonDecode(item)['id'] == alarmId);
    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  Future<void> restoreAlarms() async {
    debugPrint("restoreAlarms START");
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('scheduled_alarms') ?? [];

    _isRestoring = true;
    final now = tz.TZDateTime.now(tz.local);

    for (final item in saved) {
      final data = jsonDecode(item);
      final scheduled = tz.TZDateTime.from(
        DateTime.parse(data['dateTime']),
        tz.local,
      );

      if (scheduled.isBefore(now)) {
        debugPrint("SKIPPED (past alarm): ${data['id']}");
        continue;
      }

      await _notifications.zonedSchedule(
        id: data['id'],
        title: data['title'],
        body: data['body'],
        scheduledDate: scheduled,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            alarmChannel,
            'Alarms',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(
              data['sound'] ?? 'alarm',
            ),
            enableVibration: true,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            sound: '${data['sound'] ?? 'alarm'}.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Restored alarm ID: ${data['id']}");
    }
    _isRestoring = false;
    debugPrint("restoreAlarms END");
  }

  Future<void> cancelAlarmsByPatientId({required String patientId}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    List<String> remainingAlarms = [];

    for (String item in savedAlarms) {
      final data = jsonDecode(item);
      if (data['patientId'] == patientId) {
        await _notifications.cancel(id: data['id']);
        debugPrint(
          "Cancelled notification ID: ${data['id']} for patient: $patientId",
        );
      } else {
        remainingAlarms.add(item);
      }
    }

    await prefs.setStringList('scheduled_alarms', remainingAlarms);
    debugPrint("All alarms for patient $patientId have been removed.");
  }

  Future<void> showTestNotification() async {
    debugPrint("🚀 Triggering Instant Test Notification (v21.0.0)");

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true, // Update app icon badge
      presentSound: true, // Play the sound
      sound: 'alarm.mp3',
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      iOS: iosDetails,
      android: AndroidNotificationDetails(
        alarmChannel,
        'Alarms',
        channelDescription: 'Alarm notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound('alarm'),
      ),
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'TUH MEWS Test',
      body: 'Syntax fixed for v21.0.0!',
      notificationDetails: platformDetails,
    );
  }
}
