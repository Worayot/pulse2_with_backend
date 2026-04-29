import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

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
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Named parameter 'settings' is required in v21
    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.id}");
      },
    );

    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        alarmChannel,
        'Alarms',
        description: 'Alarm notifications',
        importance: Importance.max,
        playSound: true,
        // Set a default sound for the channel
        sound: const RawResourceAndroidNotificationSound('alarm'),
        enableVibration: true,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final canExact = await androidPlugin?.canScheduleExactNotifications();
    debugPrint("canScheduleExactNotifications: $canExact");

    await restoreAlarms();

    _isInitialized = true;
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
      final granted = await iosPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
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
          sound: '$sound.wav',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Original Context: Confirmation Notification (No Sound)
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
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint("Alarm scheduled successfully: ID=$id with sound=$sound");
    await saveAlarmToPrefs(id, dateTime, title, body, sound);
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
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.removeWhere((item) => jsonDecode(item)['id'] == id);

    savedAlarms.add(
      jsonEncode({
        'id': id,
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
            sound: '${data['sound'] ?? 'alarm'}.wav',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Restored alarm ID: ${data['id']}");
    }
    _isRestoring = false;
    debugPrint("restoreAlarms END");
  }
}
