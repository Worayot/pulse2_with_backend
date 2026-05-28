import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  // =========================
  // CHANNEL IDS
  // =========================

  static const String defaultChannel = 'alarm_channel_default_v1';
  static const String alarm2Channel = 'alarm_channel_alarm2_v1';
  static const String criticalChannel = 'alarm_channel_critical_v1';

  // =========================
  // INITIALIZE
  // =========================

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        debugPrint(
          "Notification tapped: ${response.id}",
        );
      },
      onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );

    // =========================
    // IOS PERMISSION
    // =========================

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
    >();

    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // =========================
    // ANDROID CHANNELS
    // =========================

    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    // DEFAULT SOUND CHANNEL
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        defaultChannel,
        'Default Alarm',
        description:
        'Alarm notification using alarm.mp3',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound:
        RawResourceAndroidNotificationSound(
          'alarm',
        ),
      ),
    );

    // ALARM2 SOUND CHANNEL
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        alarm2Channel,
        'Alarm 2',
        description:
        'Alarm notification using alarm2.mp3',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound:
        RawResourceAndroidNotificationSound(
          'alarm2',
        ),
      ),
    );

    // CRITICAL SOUND CHANNEL
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        criticalChannel,
        'Critical Alarm',
        description:
        'Alarm notification using critical.mp3',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound:
        RawResourceAndroidNotificationSound(
          'critical',
        ),
      ),
    );

    // =========================
    // ANDROID PERMISSIONS
    // =========================

    await android?.requestNotificationsPermission();

    await android?.requestExactAlarmsPermission();

    final canExact =
    await android?.canScheduleExactNotifications();

    debugPrint(
      "canScheduleExactNotifications = $canExact",
    );

    // =========================
    // RESTORE SAVED ALARMS
    // =========================

    await restoreAlarms();

    _isInitialized = true;

    debugPrint(
      "AlarmService initialized successfully",
    );
  }

  // =========================
  // CHANNEL HELPERS
  // =========================

  String _getChannelId(String sound) {
    switch (sound) {
      case 'alarm2':
        return alarm2Channel;

      case 'critical':
        return criticalChannel;

      case 'alarm':
      default:
        return defaultChannel;
    }
  }

  String _getChannelName(String sound) {
    switch (sound) {
      case 'alarm2':
        return 'Alarm 2';

      case 'critical':
        return 'Critical Alarm';

      case 'alarm':
      default:
        return 'Default Alarm';
    }
  }

  // =========================
  // ENSURE PERMISSIONS
  // =========================

  Future<bool> ensureAlarmPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
    >();

    if (ios != null) {
      return true;
    }

    if (android != null) {
      final notifGranted =
      await android.requestNotificationsPermission();

      if (notifGranted != true) {
        return false;
      }

      final exactGranted =
      await android.requestExactAlarmsPermission();

      return exactGranted ?? false;
    }

    return false;
  }

  // =========================
  // SET ALARM
  // =========================

  Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    String? patientID,
    String sound = 'alarm',
  }) async {
    debugPrint(
      "setAlarm called for sound: $sound",
    );

    if (!_isRestoring) {
      final allowed =
      await ensureAlarmPermission();

      if (!allowed) {
        debugPrint(
          "Alarm NOT scheduled: permission denied",
        );
        return;
      }
    }

    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled =
    tz.TZDateTime.from(
      dateTime,
      tz.local,
    );

    if (scheduled.isBefore(now)) {
      debugPrint(
        "Scheduled time in past → pushing to tomorrow",
      );

      scheduled = scheduled.add(
        const Duration(days: 1),
      );
    }

    final channelId =
    _getChannelId(sound);

    final channelName =
    _getChannelName(sound);

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription:
          'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          sound:
          RawResourceAndroidNotificationSound(
            sound,
          ),
          audioAttributesUsage:
          AudioAttributesUsage.alarm,
          enableVibration: true,
          vibrationPattern:
          Int64List.fromList([
            0,
            1000,
            500,
            1000,
          ]),
          category:
          AndroidNotificationCategory.alarm,
          visibility:
          NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: '$sound.mp3',
          interruptionLevel:
          InterruptionLevel.critical,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode
          .exactAllowWhileIdle,
    );

    debugPrint(
      "Alarm scheduled successfully: ID=$id sound=$sound",
    );

    await saveAlarmToPrefs(
      id,
      dateTime,
      title,
      body,
      sound,
      patientID,
    );
  }

  // =========================
  // SHOW TEST NOTIFICATION
  // =========================

  Future<void> showTestNotification({
    String sound = 'alarm',
  }) async {
    final channelId =
    _getChannelId(sound);

    final channelName =
    _getChannelName(sound);

    final androidDetails =
    AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
      'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound:
      RawResourceAndroidNotificationSound(
        sound,
      ),
      fullScreenIntent: true,
      category:
      AndroidNotificationCategory.alarm,
      visibility:
      NotificationVisibility.public,
      enableVibration: true,
      audioAttributesUsage:
      AudioAttributesUsage.alarm,
    );

    final iosDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$sound.mp3',
      interruptionLevel:
      InterruptionLevel.critical,
    );

    await _notifications.show(
      id: DateTime.now()
          .millisecondsSinceEpoch ~/
          1000,
      title: 'TUH MEWS Test',
      body: 'Playing sound: $sound',
      notificationDetails:
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  // =========================
  // STOP SINGLE ALARM
  // =========================

  Future<void> stopAlarm(
      int alarmId,
      ) async {
    await _notifications.cancel(
      id: alarmId,
    );

    await removeAlarmFromPrefs(
      alarmId,
    );

    debugPrint(
      'Alarm $alarmId cancelled',
    );
  }

  // =========================
  // STOP ALL ALARMS
  // =========================

  Future<void> stopAllAlarms() async {
    await _notifications.cancelAll();

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'scheduled_alarms',
    );

    debugPrint(
      'All alarms cancelled',
    );
  }

  // =========================
  // SAVE ALARM
  // =========================

  Future<void> saveAlarmToPrefs(
      int id,
      DateTime dateTime,
      String title,
      String body,
      String sound,
      String? patientID,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    List<String> savedAlarms =
        prefs.getStringList(
          'scheduled_alarms',
        ) ??
            [];

    savedAlarms.removeWhere(
          (item) =>
      jsonDecode(item)['id'] == id,
    );

    savedAlarms.add(
      jsonEncode({
        'id': id,
        'patientId': patientID,
        'dateTime':
        dateTime.toIso8601String(),
        'title': title,
        'body': body,
        'sound': sound,
      }),
    );

    await prefs.setStringList(
      'scheduled_alarms',
      savedAlarms,
    );
  }

  // =========================
  // REMOVE ALARM
  // =========================

  Future<void> removeAlarmFromPrefs(
      int alarmId,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    List<String> savedAlarms =
        prefs.getStringList(
          'scheduled_alarms',
        ) ??
            [];

    savedAlarms.removeWhere(
          (item) =>
      jsonDecode(item)['id'] ==
          alarmId,
    );

    await prefs.setStringList(
      'scheduled_alarms',
      savedAlarms,
    );
  }

  // =========================
  // RESTORE ALARMS
  // =========================

  Future<void> restoreAlarms() async {
    debugPrint(
      "restoreAlarms START",
    );

    final prefs =
    await SharedPreferences.getInstance();

    List<String> saved =
        prefs.getStringList(
          'scheduled_alarms',
        ) ??
            [];

    _isRestoring = true;

    final now =
    tz.TZDateTime.now(tz.local);

    for (final item in saved) {
      final data = jsonDecode(item);

      final scheduled =
      tz.TZDateTime.from(
        DateTime.parse(
          data['dateTime'],
        ),
        tz.local,
      );

      if (scheduled.isBefore(now)) {
        debugPrint(
          "SKIPPED past alarm: ${data['id']}",
        );

        continue;
      }

      final sound =
          data['sound'] ?? 'alarm';

      final channelId =
      _getChannelId(sound);

      final channelName =
      _getChannelName(sound);

      await _notifications.zonedSchedule(
        id: data['id'],
        title: data['title'],
        body: data['body'],
        scheduledDate: scheduled,
        notificationDetails:
        NotificationDetails(
          android:
          AndroidNotificationDetails(
            channelId,
            channelName,
            importance:
            Importance.max,
            priority:
            Priority.high,
            fullScreenIntent:
            true,
            playSound: true,
            sound:
            RawResourceAndroidNotificationSound(
              sound,
            ),
            enableVibration:
            true,
            category:
            AndroidNotificationCategory
                .alarm,
            visibility:
            NotificationVisibility
                .public,
            audioAttributesUsage:
            AudioAttributesUsage
                .alarm,
          ),
          iOS:
          DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            sound:
            '$sound.mp3',
            interruptionLevel:
            InterruptionLevel
                .critical,
          ),
        ),
        androidScheduleMode:
        AndroidScheduleMode
            .exactAllowWhileIdle,
      );

      debugPrint(
        "Restored alarm ID: ${data['id']}",
      );
    }

    _isRestoring = false;

    debugPrint(
      "restoreAlarms END",
    );
  }

  // =========================
  // CANCEL BY PATIENT ID
  // =========================

  Future<void> cancelAlarmsByPatientId({
    required String patientId,
  }) async {
    final prefs =
    await SharedPreferences.getInstance();

    List<String> savedAlarms =
        prefs.getStringList(
          'scheduled_alarms',
        ) ??
            [];

    List<String> remainingAlarms = [];

    for (String item in savedAlarms) {
      final data = jsonDecode(item);

      if (data['patientId'] ==
          patientId) {
        await _notifications.cancel(
          id: data['id'],
        );

        debugPrint(
          "Cancelled notification ID: ${data['id']}",
        );
      } else {
        remainingAlarms.add(item);
      }
    }

    await prefs.setStringList(
      'scheduled_alarms',
      remainingAlarms,
    );

    debugPrint(
      "All alarms for patient $patientId removed.",
    );
  }
}