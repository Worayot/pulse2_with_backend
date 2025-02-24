import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoPatientWidget extends StatelessWidget {
  const NoPatientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/no_patient_img.png"),
            Text(
              'noPatient'.tr(), // Example content
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            )
          ]),
    );
  }
}
