import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:pulse/mainpage/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Save preferences and navigate once done
    _savePreferences();
  }

  // Function to save preferences and navigate
  Future<void> _savePreferences() async {
    //! Change values to database's values
    await saveStringPreference('name', 'วรยศ เลี่ยมแก้ว', context);
    await saveStringPreference('nurseID', '000001', context);
    await saveStringPreference('role', 'admin', context);
    // await saveStringPreference('role', 'nurse', context);
    // await Future.delayed(Duration(seconds: 5));
    // Navigate after preferences have been saved
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const NavigationPage()),
      (route) => false, // Remove all previous routes
    );
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
                                    Color(0xff1125A4)),
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
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20),
                  ),
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
