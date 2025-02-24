import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pulse/integrated_backend/blank.dart';
import 'package:pulse/integrated_backend/data_screen.dart';
import 'package:pulse/integrated_backend/get_session_cookie.dart';
import 'package:pulse/integrated_backend/logout.dart';
import 'package:pulse/integrated_backend/register.dart'; // Import secure storage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userIDController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  final _storage = const FlutterSecureStorage();
  final url = Uri.parse('http://127.0.0.1:8000/authenticate/login');

  @override
  void initState() {
    _userIDController.text = '12345678';
    _passwordController.text = '123456';
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': _userIDController.text.trim(),
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
              Uri.parse(
                'http://127.0.0.1:8000/authenticate/create-session-cookie',
              ),
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

              // String? sessionCookie = await _storage.read(
              //   key: 'session_cookie',
              // );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BlankPage()),
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
  }

  // void init() {
  //   _userIDController.text = '12345678';
  //   _passwordController.text = '123456';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: Text('Register'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _userIDController,
                  decoration: const InputDecoration(labelText: 'userID (UID)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your userID/UID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? sessionCookie = await _storage.read(
                      key: 'session_cookie',
                    );
                    print(sessionCookie);
                  },
                  child: Text('Call'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
