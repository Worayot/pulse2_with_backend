import 'package:flutter/material.dart';
import 'package:pulse/authentication/login.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:pulse/mainpage/navigation.dart';
import 'package:pulse/services/user_services.dart';
import 'package:pulse/utils/loading_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pulse/func/notification_scheduler.dart';

class LoadingScreen extends StatefulWidget {
  final String userId;
  final String password;
  const LoadingScreen({
    super.key,
    required this.userId,
    required this.password,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final storage = FlutterSecureStorage();
  String name = 'N/A';

  Map<String, dynamic>? accountData = {};

  @override
  void initState() {
    super.initState();
    // Save preferences and navigate once done
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchUserAccount();
    await _savePreferences();
  }

  Future<void> fetchUserAccount() async {
    UserServices userServices = UserServices();
    accountData = await userServices.loadAccount(widget.userId);

    if (accountData != null && accountData!.isNotEmpty) {
      print("Successfully loaded account data.");
    } else {
      print("Failed to load account data.");
    }
  }

  // Save encrypted password
  Future<void> savePassword(String password) async {
    await storage.write(key: 'password', value: password);
  }

  Future<void> _savePreferences() async {
    if (accountData != null && accountData!.isNotEmpty) {
      String fullname =
          accountData!['fullname'] ?? 'N/A'; // Default to 'N/A' if null
      String nurseId =
          accountData!['nurse_id'] ?? 'N/A'; // Default to 'N/A' if null
      String role = accountData!['role'] ?? 'N/A'; // Default to 'N/A' if null

      // Save preferences
      await saveStringPreference('fullname', fullname, context);
      await saveStringPreference('nurseID', nurseId, context);
      await saveStringPreference('role', role, context);
      await savePassword(widget.password);

      setState(() {
        name = fullname; // Ensure the name is updated to the correct value
      });

      // Call the function to schedule notifications for this user
      await fetchAndScheduleNotification(
        accountData!['nurse_id'],
      ); // Pass userId to fetch notifications

      // Navigate to the main page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPage()),
        (route) => false,
      );
    } else {
      print("Error loading user's data");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Notification scheduling logic (You need to implement this function in your schedule_notification.dart)
  Future<void> fetchAndScheduleNotification(String userId) async {
    // Mock notification time fetch
    // Replace this with your logic to fetch user-specific notification time from Firestore or any backend
    var notificationTime = DateTime.now().add(
      Duration(seconds: 10),
    ); // Just for testing

    await _scheduleNotification(notificationTime);
  }

  Future<void> _scheduleNotification(DateTime notificationTime) async {
    // This is where you would schedule your notification using a package like flutter_local_notifications
    print('Scheduling notification for: $notificationTime');

    // Assuming you are using flutter_local_notifications, the notification scheduling would go here.
    // This is a simple mock for demonstration purposes.
    // await Future.delayed(Duration(seconds: 2));
    print('Notification scheduled for: $notificationTime');
  }

  @override
  Widget build(BuildContext context) {
    //! Change this to user's name
    return LoadingBar(context: context, name: name).build();
  }
}
