import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones(); // Initialize timezone database
    tz.setLocalLocation(
      tz.getLocation('Asia/Bangkok'),
    ); // Set your local timezone explicitly

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: darwinInitializationSettings,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Request notification permissions on iOS
    final bool? isGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (isGranted != null && isGranted) {
      print("Permission granted for notifications on iOS");
    } else {
      print(
        "Permission denied for notifications on iOS. Please enable it in settings.",
      );
      // Guide user to settings if permission denied
      openAppSettings();
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    print("Notification response received: ${response.payload}");

    if (response.payload != null) {
      final payload = jsonDecode(response.payload!);
      print("Payload type: ${payload['type']}, ID: ${payload['id']}");
    }
  }

  Future<void> scheduleNotificationAtTime(
    DateTime notificationTime,
    String message,
  ) async {
    print('Scheduling notification at: $notificationTime');
    print('Converted TZ DateTime: ${_convertToTZ(notificationTime)}');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'launch_background',
        );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Check if permission is granted before scheduling notification
    final bool? isGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (isGranted != null && isGranted) {
      print("Permission granted for notifications, scheduling notification.");
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Reminder',
          message,
          _convertToTZ(notificationTime),
          platformDetails,
          payload: '{"type": "meeting_reminder", "id": "123"}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.exact,
        );

        //! Temp
        await flutterLocalNotificationsPlugin.show(
          0,
          'Test Title',
          'This is a test notification.',
          platformDetails,
          payload: '{"type": "test", "id": "test_123"}',
        );

        print('Notification scheduled successfully for: $notificationTime');
      } catch (e) {
        print('Failed to schedule notification: $e');
      }
    } else {
      print(
        "Notification permissions not granted. Cannot schedule notification.",
      );
      // Optionally ask the user to go to the settings
      openAppSettings();
    }
  }

  tz.TZDateTime _convertToTZ(DateTime dateTime) {
    // Convert to the correct local timezone, ensuring the time is in the correct timezone
    if (dateTime.isUtc) {
      return tz.TZDateTime.from(
        dateTime.toLocal(),
        tz.local,
      ); // Convert from UTC to local
    }
    return tz.TZDateTime.from(dateTime, tz.local); // Already in local timezone
  }

  // Function to open the app settings
  Future<void> openAppSettings() async {
    final Uri url = Uri.parse('app-settings:');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      print('Opened app settings.');
    } else {
      print('Could not open settings.');
    }
  }
}
