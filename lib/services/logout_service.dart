import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import 'package:tuh_mews/state/secure_storage/secure_storage.dart';

class LogoutService {
  final NavigatorState navigator;

  LogoutService({required this.navigator});

  Future<Map<int, String>> logout() async {
    final secureStoreage = SecureStorage();
    secureStoreage.delete(key: 'session_cookie'); // Clear session cookie
    await AlarmService().stopAllAlarms();

    await navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (Route<dynamic> route) => false);

    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/authenticate/logout', //* Logout route
    );

    try {
      final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"});

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: '$e'};
    }
  }
}
