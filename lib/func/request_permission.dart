//* Used by request_permission.dart
// Request Permissions for Android 13+
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      debugPrint("✅ Notification Permission Granted");
    } else {
      debugPrint("❌ Notification Permission Denied");
    }
  }
}
