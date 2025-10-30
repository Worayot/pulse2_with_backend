import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  String _name = 'N/A';
  String _nurseID = '';

  String _role = '';

  String get name => _name;
  String get nurseID => _nurseID;

  String get role => _role;

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('fullname') ?? 'N/A';
    _nurseID = prefs.getString('nurseID') ?? 'N/A';
    _role = prefs.getString('role') ?? 'N/A';
    notifyListeners();
  }

  // Update user data in SharedPreferences
  Future<void> updateUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullname', name);
    await loadUserData();
  }

  Future<void> updateUserNurseID(String nurseID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nurseID', nurseID);
    await loadUserData();
  }

  Future<void> updateUserRole(String nurseID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    await loadUserData();
  }

  Future<void> updatePassword(String password) async {
    final storage = FlutterSecureStorage();

    await storage.write(key: 'password', value: password);
    await loadUserData();

    // Save a boolean preference and notify listeners
    Future<void> savePreference(String key, bool value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value); // Save the boolean value
      notifyListeners(); // Notify listeners that preference has changed
    }
  }
}
