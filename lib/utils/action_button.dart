import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildActionButton(FaIconData icon, VoidCallback onPressed, Color bgColor, Color iconColor, {double fontSize = 22, double buttonSize = 40}) {
  return SizedBox(
    width: buttonSize,
    height: buttonSize,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: bgColor, padding: const EdgeInsets.only(left: 0), elevation: 0),
      child: Center(child: FaIcon(icon, size: fontSize, color: iconColor)),
    ),
  );
}

Widget buildExportButton({FaIconData? icon, required VoidCallback onPressed, required Color bgColor, required Color iconColor}) {
  return SizedBox(
    width: 45,
    height: 45,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: bgColor, padding: const EdgeInsets.only(left: 2), elevation: 0),
      child:
          icon != null
              ? Center(child: FaIcon(icon, size: 25, color: iconColor))
              : const Center(
                child: SizedBox(
                  // Wrap the indicator with SizedBox
                  width: 25, // Reduced width
                  height: 25, // Reduced height
                  child: CircularProgressIndicator(
                    color: Color(0xff4B74D1),
                    strokeWidth: 3, //Added strokeWidth
                  ),
                ),
              ),
    ),
  );
}
