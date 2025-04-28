import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/services/url.dart';
import '../models/user.dart';

class UserServices {
  //* Tested
  Future<Map<String, dynamic>?> loadAccount(String userId) async {
    final _storage = FlutterSecureStorage();

    // Later in your code...
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      print('No token found');
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/sett-fetch/account_load/$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      if (response.statusCode == 200) {
        print("Successfully received response: ${response.body}");
        return jsonDecode(response.body); // Return parsed JSON data
      } else {
        print("Failed to receive data: ${response.body}");
        return null; // Return null if failed
      }
    } catch (e) {
      print("Error getting account data: $e");
      return null;
    }
  }

  //! Not tested, Won't be used
  Future<bool> getUsersList(String userId) async {
    final _storage = FlutterSecureStorage();

    // Later in your code...
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken != null) {
      print('ID Token: $idToken');
    } else {
      print('No token found');
      return false;
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/sett-fetch/users_load/$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        // body: jsonEncode(parameters),
      );

      if (response.statusCode == 200) {
        print("Successfully received note: ${response.body}");
        return true; // Success
      } else {
        print("Failed to receive note: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error getting note: $e");
      return false;
    }
  }

  //* Tested
  Future<Map<int, String>> addUser(User user) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/authenticate/signup');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(user),
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding user: $e'};
    }
  }

  //? May not be used.
  Future<Map<int, String>> getUserData(String userId) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/sett-fetch/get_user_data/$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error getting user data: $e'};
    }
  }

  //* Tested
  Future<Map<int, String>> saveUserData({
    required User newUserData,
    required String uid,
  }) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/sett-fetch/save_user/$uid');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(newUserData.toJson()),
      );
      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error saving user data: $e'};
    }
  }

  //* Tested
  Future<Map<int, String>> deleteUser(String userId) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/sett-fetch/del_user/$userId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error deleting user: $e'};
    }
  }
}
