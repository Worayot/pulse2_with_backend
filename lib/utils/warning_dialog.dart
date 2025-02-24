import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<bool> showWarningDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning".tr()),
            content: Text("proceed?".tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false
                },
                child: Text("cancel".tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true
                },
                child: Text("confirm".tr()),
              ),
            ],
          );
        },
      ) ??
      false; // Default to false if dialog is dismissed
}
