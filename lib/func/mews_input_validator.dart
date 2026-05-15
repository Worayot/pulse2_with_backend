import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tuh_mews/utils/warning_dialog.dart';

class MewsInputValidator {
  // Return proceed or not
  static Future<bool> proceedMewsInput({required BuildContext context, required bool condition, required String warningMessage}) async {
    String? warning;
    bool proceed = true;

    if (condition) {
      warning = warningMessage;
    }

    if (warning != null) {
      proceed = await showWarningDialog(context, content: warning);
    }

    return proceed;
  }

  static Future<bool> proceedTemperatureInput({required BuildContext context, required String temp}) async {
    return await proceedMewsInput(
      context: context,
      condition: (double.tryParse(temp) != null && (double.tryParse(temp)! < 30 || double.tryParse(temp)! > 45)),
      warningMessage: "outOfRange.temperature".tr(),
    );
  }

  static Future<bool> proceedHeartRateInput({required BuildContext context, required String heartRate}) async {
    return await proceedMewsInput(
      context: context,
      condition: (double.tryParse(heartRate) != null && (double.tryParse(heartRate)! < 20 || double.tryParse(heartRate)! > 300)),
      warningMessage: "outOfRange.heartRate".tr(),
    );
  }
}
