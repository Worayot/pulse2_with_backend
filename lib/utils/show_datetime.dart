import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showDateTimeDialog(BuildContext context, String dateTime) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(dateTime.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("close".tr()))],
      );
    },
  );
}
