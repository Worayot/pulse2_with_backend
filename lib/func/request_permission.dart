//* Used by request_permission.dart
// Request Permissions for Android 13+
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      print("✅ Notification Permission Granted");
    } else {
      print("❌ Notification Permission Denied");
    }
  }
}
