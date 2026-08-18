import 'package:flutter/material.dart';

class CircleWithNumber extends StatelessWidget {
  final dynamic number;
  final Color color;

  const CircleWithNumber({required this.number, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    bool isNoneMEWs = number == "-";

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: isNoneMEWs ? Colors.white : color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$number',
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            color: isNoneMEWs ? Colors.black : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0.75, 0.75), blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}
