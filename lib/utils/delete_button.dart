import 'package:flutter/material.dart';

Widget buildDeleteButton(IconData icon, VoidCallback onPressed) {
  return SizedBox(
    width: 30,
    height: 30,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(4),
          backgroundColor: Colors.red), // Execute the provided action
      child: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
    ),
  );
}
