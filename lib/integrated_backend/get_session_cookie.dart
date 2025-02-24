import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create an instance of FlutterSecureStorage
final _storage = FlutterSecureStorage();

// Function to get the value stored under the 'session_cookie' key
Future<String?> getSessionCookie() async {
  try {
    // Retrieve the session cookie value
    String? sessionCookie = await _storage.read(key: 'session_cookie');
    return sessionCookie; // returns the value or null if it doesn't exist
  } catch (e) {
    print("Error reading session cookie: $e");
    return null;
  }
}
