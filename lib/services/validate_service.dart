import 'package:flutter/material.dart';
import 'package:tuh_mews/services/logout_service.dart';
import 'package:tuh_mews/utils/flushbar.dart';

class ValidateService {
  final NavigatorState navigator;
  final Map<int, String> status;
  final bool showSuccessFlushbar;

  ValidateService({
    required this.navigator,
    required this.status,
    this.showSuccessFlushbar = false,
  });

  void validate() {
    final BuildContext context = navigator.context;
    int statusCode = status.keys.first;
    String message = '$statusCode - ${status.values.first}';

    if (statusCode == 200) {
      if (showSuccessFlushbar) {
        FlushbarService().showSuccessMessage(
          context: context,
          message: message,
        );
      }
    } else if (statusCode == 401) {
      LogoutService(navigator: navigator).logout();
      FlushbarService().showErrorMessage(context: context, message: message);
    } else {
      FlushbarService().showErrorMessage(context: context, message: message);
    }
  }
}
