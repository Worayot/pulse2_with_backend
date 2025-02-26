import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse/authentication/login.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:pulse/mainpage/navigation.dart';
import 'package:pulse/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    if (accountData != null) {
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
      await saveStringPreference('fullname', accountData!['fullname'], context);
      await saveStringPreference('nurseID', accountData!['uid'], context);
      await saveStringPreference('role', accountData!['role'], context);
      await savePassword(widget.password);

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

  @override
  Widget build(BuildContext context) {
    String name = "วรยศ เลี่ยมแก้ว";
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          width: size.width / 1.3,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color(0xffCCE9FF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: const LinearProgressIndicator(
                                minHeight: 10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xff1125A4),
                                ),
                                backgroundColor: Color(0xffB0D3EF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 50,
                        bottom: 10,
                        child: ClipRect(
                          child: Image.asset(
                            'assets/images/turtle.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '${'welcome'.tr()}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(name, style: const TextStyle(fontSize: 20)),
                ],
              ),
              Positioned(
                right: 0,
                top: size.height / 2 - 110,
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/waiter.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
