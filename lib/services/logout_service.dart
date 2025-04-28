import 'package:flutter/material.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/services/alarm_services.dart';

class LogoutService {
  final NavigatorState navigator;

  LogoutService({required this.navigator});

  void logout() async {
    await AlarmService().stopAllAlarms();

    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
