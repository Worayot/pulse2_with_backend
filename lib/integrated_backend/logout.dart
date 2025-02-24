import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pulse/integrated_backend/login.dart';
import 'package:pulse/integrated_backend/session_checker.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    bool isValid =
        await isSessionValid(); // Call the function from session_service.dart
    if (!isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ), // Navigate to LoginPage if session is invalid
      );
    }
  }

  final _storage = const FlutterSecureStorage();
  String url = 'http://127.0.0.1:8000/authenticate/logout';
  bool _isLoading = false; // Add a loading state

  Future<void> _logout() async {
    // No need to pass context anymore
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        print("Logged out successfully");

        await _storage.delete(key: "session_cookie");

        // Use Navigator.pushReplacement inside the setState callback
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        print("Logout failed: ${response.body}");
        _showSnackBar("Logout Failed: ${response.body}"); // Show error message
      }
    } catch (e) {
      print("Error logging out: $e");
      _showSnackBar("Error logging out: $e"); // Show error message
    } finally {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logout")),
      body: Center(
        // Center the content
        child: Column(
          // Use a Column to arrange widgets vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            ElevatedButton(
              onPressed:
                  _isLoading ? null : _logout, // Disable button while loading
              child:
                  _isLoading // Show loading indicator or text
                      ? const CircularProgressIndicator()
                      : const Text("Logout"),
            ),
            ElevatedButton(
              onPressed: () async {
                String? sessionCookie = await _storage.read(
                  key: 'session_cookie',
                );
                print(sessionCookie);
              },
              child: const Text('Call'),
            ),
          ],
        ),
      ),
    );
  }
}
