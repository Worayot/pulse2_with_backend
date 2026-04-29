import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await restoreAlarms();

    tz.initializeTimeZones();

    final androidSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final iosSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Alarm notifications',
      importance: Importance.max,
      playSound: true,
    );

    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(channel);

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();

    _isInitialized = true;
  }

  Future<bool> ensureAlarmPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin == null) return false;

    // Notification permission
    final notifGranted = await androidPlugin.requestNotificationsPermission();

    if (notifGranted != true) return false;

    // Exact alarm permission (Android 12+)
    final exactGranted = await androidPlugin.requestExactAlarmsPermission();

    if (exactGranted != true) {
      debugPrint("Exact alarm permission NOT granted");
      return false;
    }

    return true;
  }

  Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    String sound = 'alarm',
  }) async {
    // CHECK PERMISSION FIRST
    final allowed = await ensureAlarmPermission();

    if (!allowed) {
      debugPrint("Alarm NOT scheduled: permission denied");
      throw Exception("Alarm permission not granted");
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_v2',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: sound,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await saveAlarmToPrefs(id, dateTime, title, body);
  }

  Future<void> stopAlarm(int alarmId) async {
    await _notifications.cancel(alarmId);
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
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.add(
      jsonEncode({
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'title': title,
        'body': body,
      }),
    );

    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  // ❌ REMOVE WHEN TRIGGERED OR CANCELLED
  Future<void> removeAlarmFromPrefs(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.removeWhere((item) {
      final data = jsonDecode(item);
      return data['id'] == alarmId;
    });

    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  Future<void> restoreAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList('scheduled_alarms') ?? [];

    for (final item in saved) {
      final data = jsonDecode(item);

      await setAlarm(
        id: data['id'],
        dateTime: DateTime.parse(data['dateTime']),
        title: data['title'],
        body: data['body'],
      );
    }
  }
}
