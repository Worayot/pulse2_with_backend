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
  String name = '';
  double _progress = 0.0; // Track progress here

  Map<String, dynamic>? accountData = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchUserAccount();
    setState(() {
      _progress = 0.3;
    });

    await _savePreferences();

    // Step 3: Short delay so user sees 100% before navigation
    setState(() {
      _progress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (accountData != null && accountData!.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> fetchUserAccount() async {
    UserServices userServices = UserServices();
    accountData = await userServices.loadAccount(widget.userId);
  }

  Future<void> _savePreferences() async {
    if (accountData != null && accountData!.isNotEmpty) {
      String fullname = accountData!['fullname'] ?? 'N/A';
      String nurseId = accountData!['nurse_id'] ?? 'N/A';
      String role = accountData!['role'] ?? 'N/A';

      await saveStringPreference('fullname', fullname, context);
      setState(() {
        _progress = 0.4;
      });
      await saveStringPreference('nurseID', nurseId, context);
      setState(() {
        _progress = 0.5;
      });
      await saveStringPreference('role', role, context);
      setState(() {
        _progress = 0.6;
      });
      await storage.write(key: 'password', value: widget.password);
      setState(() {
        _progress = 0.7;
      });
      setState(() {
        name = fullname;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBar(
      context: context,
      name: name,
      progress: _progress,
    ).build();
  }
}
