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
      await Alarm.init();
      Alarm.ringStream.stream.listen((AlarmSettings triggeredAlarm) {
        debugPrint('Alarm with ID ${triggeredAlarm.id} is ringing!');
        deleteAlarmFromPrefs(triggeredAlarm.id);
      });
      await rootBundle.load('assets/audio/alarm.mp3').then((_) => true).catchError((_) => false);

      _isInitialized = true;
      debugPrint('Alarm Service Initialized');
    }
  }

  Future<void> setAlarm(AlarmSettings alarmSettings) async {
    await Alarm.set(alarmSettings: alarmSettings);
    await saveAlarmToPrefs(alarmSettings);
    debugPrint('Alarm set and saved in preference with ID: ${alarmSettings.id}, Time: ${alarmSettings.dateTime}');
  }

  Future<void> stopAlarm(int alarmId) async {
    await Alarm.stop(alarmId);
    await removeAlarmFromPrefs(alarmId); // Implement this if needed
    // debugPrint('Alarm $alarmId stopped and has been removed from preference');
  }

  Future<void> stopAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedAlarms = prefs.getStringList('scheduled_alarms');

    if (savedAlarms != null) {
      for (final alarmJson in savedAlarms) {
        try {
          final alarmMap = jsonDecode(alarmJson);
          final int? alarmId = alarmMap['id'];
          if (alarmId != null) {
            await Alarm.stop(alarmId);
            debugPrint('Stopped alarm with ID: $alarmId');
          }
        } catch (e) {
          debugPrint('Error decoding alarm JSON: $e');
        }
      }
      await prefs.remove('scheduled_alarms');
      debugPrint('All alarms stopped and removed from preferences.');
    } else {
      debugPrint('No alarms found in preferences to stop.');
    }
  }

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

    await prefs.setStringList('scheduled_alarms', savedAlarms);
  }

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
