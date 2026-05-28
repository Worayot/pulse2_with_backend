import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tuh_mews/utils/warning_dialog.dart';

class MewsInputValidator {
  String _warningMessage = '';

  String get warngingMessage => _warningMessage;

  set warningMessage(String value) {
    _warningMessage = value.trim();
  }

  Future<bool> validateInput({required BuildContext ctx, required String temp, required String heartRate}) async {
    validateTemperatureInput(context: ctx, temp: temp);
    validateHeartRateInput(context: ctx, heartRate: heartRate);

    _warningMessage = _warningMessage.trim();
    return _warningMessage.isEmpty ? true : await showWarningDialog(ctx, content: _warningMessage);
  }

  void proceedMewsInputReturnWarnMessage({required BuildContext context, required bool condition, required String warning}) async {
    if (condition) {
      _warningMessage = warngingMessage + ('\n$warning');
    }
  }

  void validateTemperatureInput({required BuildContext context, required String temp}) async {
    return proceedMewsInputReturnWarnMessage(
      context: context,
      condition: (double.tryParse(temp) != null && (double.tryParse(temp)! < 30 || double.tryParse(temp)! > 45)),
      warning: "outOfRange.temperature".tr(),
    );
  }

  void validateHeartRateInput({required BuildContext context, required String heartRate}) async {
    return proceedMewsInputReturnWarnMessage(
      context: context,
      condition: (double.tryParse(heartRate) != null && (double.tryParse(heartRate)! < 20 || double.tryParse(heartRate)! > 300)),
      warning: "outOfRange.heartRate".tr(),
    );
  }
}
