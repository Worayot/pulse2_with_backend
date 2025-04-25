import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';

Widget infoTextField({
  required String title,
  required TextEditingController controller,
  required Color boxColor,
  required double minWidth,
  required double fontSize,
  bool? numberOnly,
  bool? blockEditing,
  String? hintText,
  String? Function(String?)? validator,
}) {
  bool block = blockEditing ?? false ? false : true;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            minWidth: minWidth,
          ),
          height: 40,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 0,
              left: 12,
              right: 12,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType:
                  numberOnly == true
                      ? TextInputType.number
                      : TextInputType.text,
              inputFormatters:
                  numberOnly == true
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : [],
              maxLines: 1,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
              ),
              enabled: block,
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
      ],
    ),
  );
}
