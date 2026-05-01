import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/authentication/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuh_mews/services/url.dart';
import 'package:tuh_mews/state/secure_storage/secure_storage.dart';
import 'package:tuh_mews/utils/flushbar.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool rememberMe = false;
  late TextEditingController _nurseIDController;
  late TextEditingController _passwordController;
  int _selectedLanguageIndex = 1;
  bool isLoading = false;
  String errorMessage = '';
  final secureStorage = SecureStorage();

  @override
  void initState() {
    _nurseIDController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final nurseId = await secureStorage.read(key: 'nurseId');
      final password = await secureStorage.read(key: 'password');
      final String remember = await secureStorage.read(key: 'rememberMe') ?? 'false';

      if (remember == 'true') {
        setState(() {
          rememberMe = true;
        });
      } else {
        rememberMe = false;
      }

      _nurseIDController.text = nurseId ?? '';
      _passwordController.text = password ?? '';

      _loadSelectedLocale();
    });
    super.initState();
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
    FocusScope.of(context).unfocus();

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (rememberMe) {
      await secureStorage.write(key: 'nurseId', value: _nurseIDController.text.trim());
      await secureStorage.write(key: 'password', value: _passwordController.text.trim());
      await secureStorage.write(key: 'rememberMe', value: rememberMe.toString());
    } else {
      secureStorage.delete(key: 'nurseId');
      secureStorage.delete(key: 'password');
      secureStorage.delete(key: 'rememberMe');
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String url = URL().getServerURL();
      Uri loginUrl = Uri.parse('$url/authenticate/login');

      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': _nurseIDController.text.trim(), 'password': _passwordController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String customToken = data['custom_token'];

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(customToken);
        final String? idToken = await userCredential.user?.getIdToken();

        if (idToken != null) {
          final cookieUrl = Uri.parse('$url/authenticate/create-session-cookie');
          final sessionResponse = await http.post(cookieUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'id_token': idToken}));

          if (sessionResponse.statusCode == 200) {
            final sessionData = jsonDecode(sessionResponse.body);
            try {
              await secureStorage.write(key: 'session_cookie', value: sessionData['session_cookie'], expiry: Duration(days: 7));
            } catch (e) {
              rethrow;
            }

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoadingScreen(userId: _nurseIDController.text, password: _passwordController.text)),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            if (mounted) {
              FlushbarService().showErrorMessage(context: context, message: "Failed to create session: ${sessionResponse.body}");
            }

            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          FlushbarService().showErrorMessage(context: context, message: "Login failed: ${response.body}");
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        FlushbarService().showErrorMessage(context: context, message: '$e');
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 0,
                    child: SizedBox(width: size.width / 3, child: Image.asset('assets/images/img_login_top.png', fit: BoxFit.contain)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: size.height * 0.1),
                        Align(alignment: Alignment.center, child: Text('MEWS', style: TextStyle(fontSize: size.height * 0.095, fontWeight: FontWeight.bold, color: Colors.black))),
                        Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                          color: const Color(0xffE0EAFF),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: size.width / 10, horizontal: size.width / 15),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ToggleButtons(
                                        isSelected: [_selectedLanguageIndex == 0, _selectedLanguageIndex == 1],
                                        onPressed: _toggleLanguage,
                                        borderRadius: BorderRadius.circular(10),
                                        selectedColor: Colors.white,
                                        fillColor: const Color(0xff1225A4),
                                        color: Colors.black,
                                        constraints: const BoxConstraints(minWidth: 70, minHeight: 36),
                                        children: const [Text('English'), Text('ไทย')],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(children: [Text("nurseID".tr(), style: const TextStyle(fontSize: 16), textAlign: TextAlign.left)]),
                                  TextFormField(
                                    controller: _nurseIDController,
                                    decoration: InputDecoration(
                                      hintText: "\t\t${"fillInNurseID".tr()}",
                                      border: const UnderlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "plsEnterNurseID".tr(); // Use .tr() if localized
                                      }
                                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                                        return "nurseIDMustBeANumber".tr();
                                      }
                                      return null; // No error
                                    },
                                  ),

                                  SizedBox(height: size.height / 50),
                                  Row(children: [Text("password".tr(), style: const TextStyle(fontSize: 16), textAlign: TextAlign.left)]),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      hintText: "\t\t${"fillInPassword".tr()}",
                                      border: const UnderlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
                                      suffixIcon: IconButton(
                                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: obscurePassword,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "plsEnterPassword".tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap(16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        focusColor: const Color(0xff1225A4),
                                        activeColor: const Color(0xff1225A4),
                                        value: rememberMe,
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setState(() {
                                            rememberMe = value;
                                            secureStorage.write(key: 'rememberMe', value: (value).toString());
                                          });
                                        },
                                      ),
                                      Text("rememberMe?".tr()),
                                    ],
                                  ),
                                  const Gap(16),
                                  SizedBox(
                                    width: size.width * 0.5,
                                    height: size.height * 0.07,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff1225A4),
                                        padding: const EdgeInsets.symmetric(vertical: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                        elevation: 2,
                                      ),
                                      onPressed: _login,
                                      child:
                                          isLoading
                                              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                              : Text("login".tr(), style: const TextStyle(fontSize: 22, color: Colors.white)),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
