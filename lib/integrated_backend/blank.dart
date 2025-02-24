import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:pulse/integrated_backend/logout.dart';
import 'sse_service.dart';

class BlankPage extends StatefulWidget {
  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  int time = 5 * 60; // 5 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    // Update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        _timer.cancel(); // Stop the timer when the countdown reaches 0
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Convert time to minutes and seconds format
    String minutes = (time ~/ 60).toString().padLeft(2, '0');
    String seconds = (time % 60).toString().padLeft(2, '0');
    String formattedTime = '$minutes:$seconds';

    return Scaffold(
      appBar: AppBar(title: Text("Real-Time Patients")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedTime, // Display the formatted countdown
            style: TextStyle(fontSize: 50),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogoutPage()),
                );
              },
              child: Text('To Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
