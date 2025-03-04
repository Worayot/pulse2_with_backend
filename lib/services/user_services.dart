import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulse/models/note.dart';
import 'package:pulse/models/parameters.dart';
import '../models/user.dart';
import 'server_url.dart';

class UserServices {
  //* Tested
  Future<Map<String, dynamic>?> loadAccount(String userId) async {
    final url = Uri.parse('$baseUrl/sett-fetch/account_load/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
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
    final url = Uri.parse('$baseUrl/sett-fetch/users_load/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
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
  Future<bool> addUser(User user) async {
    final url = Uri.parse('$baseUrl/authenticate/signup');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user),
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

  //? May not be used.
  Future<bool> getUserData(String userId) async {
    final url = Uri.parse('$baseUrl/sett-fetch/get_user_data/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(user),
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
  saveUserData({required User newUserData, required String uid}) async {
    final url = Uri.parse('$baseUrl/sett-fetch/save_user/$uid');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newUserData.toJson()),
      );

      if (response.statusCode == 200) {
        print("Successfully edited user's data: ${response.body}");
        return true; // Success
      } else if (response.statusCode == 404) {
        print("User not found: ${response.body}");
      } else {
        print("Failed to edit user's data: ${response.body}");
      }
      return false; // Failure
    } catch (e) {
      print("Error during request: $e");
      return false;
    }
  }

  //* Tested
  Future<bool> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/sett-fetch/del_user/$userId');

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(user),
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
}
