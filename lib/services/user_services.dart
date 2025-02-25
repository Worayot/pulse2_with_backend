import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulse/models.dart/note.dart';
import 'package:pulse/models.dart/parameters.dart';
import '../models.dart/user.dart';
import 'url.dart';

class UserServices {
  //! Not tested
  Future<bool> loadAccount(String userId) async {
    final url = Uri.parse('$baseUrl/sett-fetch/account_load/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientId),
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

  //! Not tested
  Future<bool> getUsersList(String userId) async {
    final url = Uri.parse('$baseUrl/sett-fetch/$userId');

    try {
      final response = await http.post(
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

  //! Not tested
  Future<bool> addUser(User user) async {
    final url = Uri.parse('$baseUrl/sett-fetch/add_notes');

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
}
