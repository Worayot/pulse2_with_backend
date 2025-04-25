// alarm_service.dart
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();

  factory AlarmService() => _instance;

  AlarmService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await Alarm.init(); // Corrected: Removed showDebugLogs
      Alarm.ringStream.stream.listen((AlarmSettings triggeredAlarm) {
        print('Alarm with ID ${triggeredAlarm.id} is ringing!');
        deleteAlarmFromPrefs(triggeredAlarm.id); // Use your delete function
        // Add your logic to handle the ringing alarm (e.g., show a dialog, play sound)
      });
      final fileExists = await rootBundle
          .load('assets/audio/alarm.mp3')
          .then((_) => true)
          .catchError((_) => false);
      print("Audio file exists: $fileExists");

      _isInitialized = true;
      print('Alarm Service Initialized');
    }
  }

  Future<void> setAlarm(AlarmSettings alarmSettings) async {
    await Alarm.set(alarmSettings: alarmSettings);
    await saveAlarmToPrefs(alarmSettings); // Use your save function
    print(
      'Alarm set and saved in preference with ID: ${alarmSettings.id}, Time: ${alarmSettings.dateTime}',
    );
  }

  Future<void> stopAlarm(int alarmId) async {
    await Alarm.stop(alarmId);
    await removeAlarmFromPrefs(alarmId); // Implement this if needed
    print('Alarm $alarmId stopped and has been removed from preference');
  }

  // Your preference functions (move these here)
  Future<void> saveAlarmToPrefs(AlarmSettings alarmSettings) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.add(
      jsonEncode({
        'id': alarmSettings.id,
        'dateTime': alarmSettings.dateTime.toIso8601String(),
        'title': alarmSettings.notificationSettings.title,
        'body': alarmSettings.notificationSettings.body,
      }),
    );

    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  Future<void> deleteAlarmFromPrefs(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.removeWhere((alarmJson) {
      final alarmMap = jsonDecode(alarmJson);
      return alarmMap['id'] == alarmId;
    });

    print('Alarm $alarmId has been removed from preference');

    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

  // Implement removeAlarmFromPrefs if you need a separate function
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
