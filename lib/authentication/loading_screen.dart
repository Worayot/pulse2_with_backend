import 'package:flutter/material.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/services/user_services.dart';
import 'package:tuh_mews/utils/loading_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoadingScreen extends StatefulWidget {
  final String userId;
  final String password;
  const LoadingScreen({super.key, required this.userId, required this.password});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final storage = FlutterSecureStorage();
  String name = '';

  Map<String, dynamic>? accountData = {};

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async {
    await fetchUserAccount();
    await _savePreferences();
  }

  Future<void> fetchUserAccount() async {
    UserServices userServices = UserServices();
    accountData = await userServices.loadAccount(widget.userId);
  }

  // Save encrypted password
  Future<void> savePassword(String password) async {
    await storage.write(key: 'password', value: password);
  }

  Future<void> _savePreferences() async {
    if (accountData != null && accountData!.isNotEmpty) {
      String fullname = accountData!['fullname'] ?? 'N/A'; // Default to 'N/A' if null
      String nurseId = accountData!['nurse_id'] ?? 'N/A'; // Default to 'N/A' if null
      String role = accountData!['role'] ?? 'N/A'; // Default to 'N/A' if null

      // Save preferences
      await saveStringPreference('fullname', fullname, context);
      await saveStringPreference('nurseID', nurseId, context);
      await saveStringPreference('role', role, context);
      await savePassword(widget.password);

      setState(() {
        name = fullname;
      });

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const NavigationPage()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(context: context, name: name).build();
  }
}
