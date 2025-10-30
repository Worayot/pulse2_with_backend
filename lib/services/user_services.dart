import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:http/http.dart' as http;
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import '../models/user.dart';
import 'package:bcrypt/bcrypt.dart';

class UserServices {
  Future<Map<String, dynamic>?> loadAccount(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        return null;
      }

      final data = docSnap.data();
      final result = {"id": docSnap.id, ...?data};

      return result;
    } catch (e) {
      return null;
    }
  }

  //* Tested
  Future<Map<int, String>> addUser(User user) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/authenticate/signup');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode(user));

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding user: $e'};
    }
  }

  // Tested
  Future<Map<int, String>> saveUserData({
    required User newUserData,
    required String uid, // This is your 'nurse_id'
  }) async {
    try {
      final userMap = newUserData.toJson();

      if (userMap['password'] != null && userMap['password'].toString().isNotEmpty) {
        final password = userMap['password'].toString();

        final String hashed = BCrypt.hashpw(password, BCrypt.gensalt());

        userMap['password'] = hashed;
      }

      final usersRef = FirebaseFirestore.instance.collection('users');
      final query = await usersRef.where('nurse_id', isEqualTo: uid).limit(1).get();

      if (query.docs.isEmpty) {
        return {404: 'User not found'};
      }

      final userDoc = query.docs.first.reference;
      await userDoc.update(userMap);

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

    final url = Uri.parse('${URL().getServerURL()}/sett-fetch/del_user/$userId');

    try {
      final response = await http.delete(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"});

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          return {response.statusCode: decoded['message'].toString()};
        }
      } catch (_) {}

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error deleting user: $e'};
    }
  }
}
