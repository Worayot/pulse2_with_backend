import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:http/http.dart' as http;
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import '../models/user.dart';

class UserServices {
  //* Tested
  // Future<Map<String, dynamic>?> loadAccount(String userId) async {
  //   // final _storage = FlutterSecureStorage();
  //   // String? idToken = await _storage.read(key: 'id_token');
  //   String? idToken = await SessionService().getIdToken();

  //   if (idToken == null) {}
  //   final url = Uri.parse('${URL().getServerURL()}/sett-fetch/account_load/$userId');

  //   try {
  //     final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"});

  //     if (response.statusCode == 200) {
  //       // print("Successfully received response: ${response.body}");
  //       return jsonDecode(response.body); // Return parsed JSON data
  //     } else {
  //       // print("Failed to receive data: ${response.body}");
  //       return null; // Return null if failed
  //     }
  //   } catch (e) {
  //     // print("Error getting account data: $e");
  //     return null;
  //   }
  // }

  // Not test yet
  Future<Map<String, dynamic>?> loadAccount(String userId) async {
    try {
      // Step 1: Ensure current Firebase user exists
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }

      // Step 2: Optionally verify user identity (optional, depends on your app logic)
      // You can skip this if userId != Firebase UID (e.g., using nurse_id instead)
      if (user.uid != userId) {
        // Still allow access if you want (same as backend token verification bypass)
      }

      // Step 3: Read Firestore document
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        return null;
      }

      // Step 4: Match backend response shape
      final data = docSnap.data();
      final result = {"id": docSnap.id, ...?data};

      // Step 5: Return same type as original (Map<String, dynamic>?)
      return result;
    } catch (e) {
      return null;
    }
  }

  //* Tested
  Future<Map<int, String>> addUser(User user) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

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

  //* Tested
  // Future<Map<int, String>> saveUserData({
  //   required User newUserData,
  //   required String uid,
  // }) async {
  //   // final _storage = FlutterSecureStorage();
  //   // String? idToken = await _storage.read(key: 'id_token');
  //   String? idToken = await SessionService().getIdToken();

  //   if (idToken == null) {
  //     return {401: 'No token found'};
  //   }
  //   final url = Uri.parse('${URL().getServerURL()}/sett-fetch/save_user/$uid');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $idToken",
  //       },
  //       body: jsonEncode(newUserData.toJson()),
  //     );
  //     return {response.statusCode: response.body};
  //   } catch (e) {
  //     return {500: 'Error saving user data: $e'};
  //   }
  // }

  // Tested
  Future<Map<int, String>> saveUserData({
    required User newUserData,
    required String uid,
  }) async {
    try {
      // Step 1: Ensure user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return {401: 'No authenticated user found'};
      }

      // Step 2: Convert to map for Firestore update
      final userMap = newUserData.toJson();

      // Step 3: Hash password if not empty
      if (userMap['password'] != null &&
          userMap['password'].toString().isNotEmpty) {
        final password = userMap['password'].toString();
        final hashed = sha256.convert(utf8.encode(password)).toString();
        userMap['password'] = hashed;
      }

      // Step 4: Find Firestore document by nurse_id
      final usersRef = FirebaseFirestore.instance.collection('users');
      final query =
          await usersRef.where('nurse_id', isEqualTo: uid).limit(1).get();

      if (query.docs.isEmpty) {
        return {404: 'User not found'};
      }

      // Step 5: Update Firestore record
      final userDoc = query.docs.first.reference;
      await userDoc.update(userMap);

      // Step 6: Return same type/format as backend response
      return {200: 'User updated successfully'};
    } catch (e) {
      return {500: 'Error saving user data: $e'};
    }
  }

  //* Tested
  Future<Map<int, String>> deleteUser(String userId) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'Unauthorized: No token found'};
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

      // Try to parse JSON message if possible
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          return {response.statusCode: decoded['message'].toString()};
        }
      } catch (_) {
        // fallback to raw text if body isn't JSON
      }

      // Fallback: return raw response
      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error deleting user: $e'};
    }
  }
}
