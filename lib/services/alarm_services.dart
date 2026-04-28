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

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    final androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosSettings = const DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(initSettings);

    _isInitialized = true;
    debugPrint('Alarm Service Initialized');
  }

  // 🔔 SET ALARM
  Future<void> setAlarm({required int id, required DateTime dateTime, required String title, required String body}) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // 👈 makes it behave like alarm
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    await saveAlarmToPrefs(id, dateTime, title, body);

    debugPrint('Alarm scheduled: ID=$id Time=$dateTime');
  }

  // 🛑 STOP ALARM
  Future<void> stopAlarm(int alarmId) async {
    await _notifications.cancel(alarmId);
    await removeAlarmFromPrefs(alarmId);

    debugPrint('Alarm $alarmId cancelled');
  }

  // 🛑 STOP ALL
  Future<void> stopAllAlarms() async {
    await _notifications.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_alarms');

    debugPrint('All alarms cancelled');
  }

  // 💾 SAVE
  Future<void> saveAlarmToPrefs(int id, DateTime dateTime, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.add(jsonEncode({'id': id, 'dateTime': dateTime.toIso8601String(), 'title': title, 'body': body}));

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
}
