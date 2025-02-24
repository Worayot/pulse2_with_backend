import 'package:flutter/material.dart';

Color getColor(String num) {
  if (num == "0" || num == "1" || num == "2") {
    return Colors.green;
  } else if (num == "3") {
    return Colors.yellow.shade700;
  } else if (num == "4") {
    return Colors.orange;
  } else if (num == "-") {
    return Colors.black;
  } else {
    return Colors.red;
  }
}
