import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _storage = const FlutterSecureStorage();
final url = Uri.parse(
  'http://127.0.0.1:8000/authenticate/verify_session_cookie',
);

// Function to verify session validity
Future<bool> isSessionValid() async {
  try {
    // Read the session cookie from secure storage
    String? sessionCookie = await _storage.read(key: 'session_cookie');

    if (sessionCookie == null) {
      print("No session cookie found");
      return false; // No session cookie found, return false
    }

    // Send a POST request to the FastAPI server to verify the session cookie
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': sessionCookie}),
    );

    if (response.statusCode == 200) {
      // Session is valid
      print("Session is valid");
      return true;
    } else {
      // Session is invalid or expired, delete the session cookie
      print("Session expired or invalid");
      await _storage.delete(
        key: 'session_cookie',
      ); // Delete the session cookie from secure storage
      return false;
    }
  } catch (e) {
    // Handle errors such as network failure
    print("Error checking session: $e");
    return false;
  }
}
