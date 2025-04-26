import 'package:another_flushbar/flushbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FlushbarService {
  void showCustomFlushbar({
    required BuildContext context,
    required String title,
    required String message,
    Color? titleColor,
    Color? backgroundColor,
    Color? messageColor,
    int? duration,
  }) {
    Flushbar(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(8),
      message: message,
      animationDuration: Duration(seconds: 1),
      duration: Duration(seconds: duration ?? 1),
      title: title,
      backgroundColor: backgroundColor ?? Color(0xffE0EAFF),
      messageColor: messageColor ?? Colors.black,
      titleColor: titleColor ?? Colors.black,
      isDismissible: true,
    ).show(context);
  }

  void showSuccessMessage({
    required BuildContext context,
    String? title,
    required String message,
  }) {
    showCustomFlushbar(
      context: context,
      title: title ?? 'success'.tr(),
      message: message,
      titleColor: Colors.green,
      messageColor: Colors.black,
      backgroundColor: Color(0xffD1FFBD),
      duration: 2,
    );
  }

  void showErrorMessage({
    required BuildContext context,
    String? title,
    required String message,
  }) {
    showCustomFlushbar(
      context: context,
      title: title ?? 'error'.tr(),
      message: message,
      backgroundColor: Color(0xffFFDDE4),
      titleColor: Colors.red,
      messageColor: Colors.black,
      duration: 2,
    );
  }
}
