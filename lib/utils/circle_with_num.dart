import 'package:flutter/material.dart';

class CircleWithNumber extends StatelessWidget {
  final dynamic number; // The number to be displayed in the circle
  final Color color; // The color of the circle

  // Constructor for initializing the number and color
  const CircleWithNumber({
    required this.number,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isNoneMEWs = number == "-";

    return Container(
      width: 50, // Circle width
      height: 50, // Circle height
      decoration: BoxDecoration(
        color:
            isNoneMEWs ? Colors.white : color, // Background color of the circle
        shape: BoxShape.circle, // Making the container circular
      ),
      child: Center(
        child: Text(
          '$number', // Displaying the number
          style: TextStyle(
            color: isNoneMEWs
                ? Colors.black
                : Colors.white, // White color for the text
            fontSize: 22, // Font size for the number
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color:
                    Colors.black.withOpacity(0.5), // Shadow color with opacity
                offset:
                    const Offset(0.5, 0.5), // Horizontal and vertical offset
                blurRadius: 1, // Blur radius
              ),
            ], // Bold number
          ),
        ),
      ),
    );
  }
}
