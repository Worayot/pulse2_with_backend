import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> savePreference(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<void> savePatientPreference(List<String> patients) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('patient_list', patients);
}

Future<void> saveStringPreference(String key, String value, BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);

  final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

  if (key == 'name') {
    userDataProvider.updateUserName(value);
  } else if (key == 'password') {
    userDataProvider.updatePassword(value);
  } else if (key == 'nurseID') {
    userDataProvider.updateUserNurseID(value);
  } else if (key == 'role') {
    userDataProvider.updateUserRole(value);
  }
}

Future<void> saveIntPreference(String key, int value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

Future<bool> loadBooleanPreference(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

Future<String?> loadStringPreference(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<int?> loadIntPreference(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future<void> saveAlarmToPrefs({required int id, required DateTime dateTime, required String title, required String body}) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

  savedAlarms.add(jsonEncode({'id': id, 'dateTime': dateTime.toIso8601String(), 'title': title, 'body': body}));

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
