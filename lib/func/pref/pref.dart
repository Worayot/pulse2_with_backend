import 'dart:convert';

import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to save a boolean preference
Future<void> savePreference(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value); // Save the boolean value
}

// Function to save patient preference
Future<void> savePatientPreference(List<String> patients) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('patient_list', patients);
}

// Function to save a string preference
Future<void> saveStringPreference(
  String key,
  String value,
  BuildContext context,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value); // Save the string value

  final userDataProvider = Provider.of<UserDataProvider>(
    context,
    listen: false,
  );

  // Ensure correct values are updated based on the key
  if (key == 'name') {
    userDataProvider.updateUserName(value);
  } else if (key == 'nurseID') {
    userDataProvider.updateUserNurseID(value);
  } else if (key == 'role') {
    userDataProvider.updateUserRole(value);
  }
}

// Function to save an integer preference
Future<void> saveIntPreference(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value); // Save the integer value
}

// Function to load a boolean preference
Future<bool> loadBooleanPreference(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false; // Default to false if no value exists
}

// Function to load a string preference
Future<String?> loadStringPreference(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key); // Returns null if no value exists
}

// Function to load an integer preference
Future<int?> loadIntPreference(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key); // Returns null if no value exists
}

// Function to load patient preference
// Future<List<String>> loadPatientPreference(String key) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getStringList('patient_list') ?? [];
// }

// Future<void> addPatientID(String newID) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> patientIDs = prefs.getStringList('patient_ids') ?? [];

//   if (!patientIDs.contains(newID)) {
//     patientIDs.add(newID);
//     await prefs.setStringList('patient_ids', patientIDs);
//   }
//   print('Updated List After Adding: $patientIDs'); // Debugging
// }

// Future<void> removePatientID(String id) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> patientIDs = prefs.getStringList('patient_ids') ?? [];

//   patientIDs.remove(id);
//   await prefs.setStringList('patient_ids', patientIDs);
//   // print('Updated List After Removing: $patientIDs'); // Debugging
// }

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

  // Find the alarm with the given ID and remove it from the list
  savedAlarms.removeWhere((alarmJson) {
    final alarmMap = jsonDecode(alarmJson);
    return alarmMap['id'] == alarmId;
  });

  // Save the updated list back to SharedPreferences
  await prefs.setStringList('scheduled_alarms', savedAlarms);
}
