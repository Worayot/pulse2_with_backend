import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pulse/authentication/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nurseIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedLanguageIndex = 1;
  bool _isLoading = false;
  String _errorMessage = '';
  final _storage = const FlutterSecureStorage();
  final loginUrl = Uri.parse('http://0.0.0.0:8000/authenticate/login');
  final cookieUrl = Uri.parse(
    'http://0.0.0.0:8000/authenticate/create-session-cookie',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSelectedLocale();
    });
  }

  Future<void> _loadSelectedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode == 'en') {
      setState(() {
        _selectedLanguageIndex = 0;
        context.setLocale(const Locale('en', 'US'));
      });
    } else {
      setState(() {
        _selectedLanguageIndex = 1;
        context.setLocale(const Locale('th', 'TH')); // Default to Thai
      });
    }
  }

  Future<void> _saveSelectedLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }

  void _toggleLanguage(int index) {
    Locale newLocale;
    if (index == 0) {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = const Locale('th', 'TH');
    }

    setState(() {
      _selectedLanguageIndex = index;
      context.setLocale(newLocale);
      _saveSelectedLocale(newLocale);
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': _nurseIDController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String customToken = data['custom_token'];

        // Step 1: Sign in with the custom token
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCustomToken(customToken);
        final String? idToken =
            await userCredential.user?.getIdToken(); // Get Firebase ID Token

        if (idToken != null) {
          print("Firebase ID Token: $idToken");

          // Step 2: Send ID Token to FastAPI to create a session
          final sessionResponse = await http.post(
            cookieUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          );

          if (sessionResponse.statusCode == 200) {
            final sessionData = jsonDecode(sessionResponse.body);
            try {
              await _storage.write(
                key: 'session_cookie',
                value: sessionData['session_cookie'],
              );

              print("Session cookie stored successfully");
            } catch (e) {
              print("Error storing session cookie: $e");
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoadingScreen(),
              ), // For example, navigating to the Login screen
              (Route<dynamic> route) => false, // Removes all previous screens
            );
          } else {
            print("Failed to create session: ${sessionResponse.body}");
          }
        }
      } else {
        print("Login failed: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center content (login form, etc.)
          Center(
            child: Padding(
              padding: EdgeInsets.all(size.width / 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: size.height * 0.1),
                  Card(
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    color: const Color(0xffE0EAFF),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: size.width / 10,
                        horizontal: size.width / 15,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ToggleButtons(
                                  isSelected: [
                                    _selectedLanguageIndex == 0,
                                    _selectedLanguageIndex == 1,
                                  ],
                                  onPressed: _toggleLanguage,
                                  borderRadius: BorderRadius.circular(10),
                                  selectedColor: Colors.white,
                                  fillColor: const Color(0xff1225A4),
                                  color: Colors.black,
                                  constraints: const BoxConstraints(
                                    minWidth: 70,
                                    minHeight: 36,
                                  ),
                                  children: const [
                                    Text('English'),
                                    Text('ไทย'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "nurseID".tr(),
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _nurseIDController,
                              decoration: InputDecoration(
                                hintText: "\t\t${"fillInNurseID".tr()}",
                                border: const UnderlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter a Nurse ID"; // Use .tr() if localized
                                }
                                if (!RegExp(r'^\d+$').hasMatch(value)) {
                                  return "Nurse ID must be a number";
                                }
                                return null; // No error
                              },
                            ),

                            SizedBox(height: size.height / 50),
                            Row(
                              children: [
                                Text(
                                  "password".tr(),
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: "\t\t${"fillInPassword".tr()}",
                                border: const UnderlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your password".tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: size.height * 0.05),
                            SizedBox(
                              width: size.width * 0.5,
                              height: size.height * 0.07,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xff1225A4,
                                  ).withOpacity(0.65),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: _login,
                                child: Text(
                                  "login".tr(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size.height / 12,
            left: -36, // This sticks the image to the left side of the screen
            child: SizedBox(
              width: size.width * 0.35, // Adjust width as necessary
              height: size.width * 0.35, // Adjust height as necessary
              // width: 200, // Adjust width as necessary
              // height: 200, // Adjust height as necessary
              child: Image.asset(
                'assets/images/img_login_top.png',
                fit: BoxFit.contain, // Adjust the image's fit to your needs
              ),
            ),
          ),
          Positioned.fill(
            top: -size.height / 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                // textAlign: TextAlign.center,
                'MEWS',
                style: TextStyle(
                  fontSize: size.height * 0.095,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Bottom image positioned above the green card
          Positioned(
            bottom: 0, // Adjust bottom position so it overlaps with the card
            left: 0,
            right: 0,
            child: SizedBox(
              width: size.width / 4.5, // Full width of the screen
              height: size.height / 4.5, // Adjust height as needed
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/img_login_bottom.png',
                  fit:
                      BoxFit
                          .contain, // Stretch the image to cover the container
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
