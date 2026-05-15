import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PasswordValidationWidget extends StatelessWidget {
  final String password;

  const PasswordValidationWidget({super.key, required this.password});

  Widget _buildItem(bool isValid, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isValid ? Icons.check_circle : Icons.cancel, color: isValid ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(text, softWrap: true, overflow: TextOverflow.visible, style: TextStyle(fontSize: 14, color: isValid ? Colors.green : Colors.red))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(PasswordValidator.hasMinLength(password), "password_rules.min_length".tr()),
        _buildItem(PasswordValidator.hasUppercase(password), "password_rules.uppercase".tr()),
        _buildItem(PasswordValidator.hasLowercase(password), "password_rules.lowercase".tr()),
        _buildItem(PasswordValidator.hasDigit(password), "password_rules.digit".tr()),
        _buildItem(PasswordValidator.hasSpecial(password), "password_rules.special_char".tr()),
      ],
    );
  }
}

class PasswordValidator {
  static bool hasUppercase(String input) => RegExp(r'[A-Z]').hasMatch(input);
  static bool hasLowercase(String input) => RegExp(r'[a-z]').hasMatch(input);
  static bool hasDigit(String input) => RegExp(r'[0-9]').hasMatch(input);
  static bool hasSpecial(String input) => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(input);
  static bool hasMinLength(String input) => input.length >= 8;

  static bool isValid(String input) {
    return hasUppercase(input) && hasLowercase(input) && hasDigit(input) && hasSpecial(input) && hasMinLength(input);
  }
}
