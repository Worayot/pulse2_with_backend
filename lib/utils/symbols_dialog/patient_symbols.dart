import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget patientSymbols() {
  return Container(
    width: 800,
    constraints: const BoxConstraints(
      maxHeight: 210,
    ),
    child: Column(
      children: [
        const SizedBox(height: 30),
        Column(
          children: [
            Row(
              children: [
                const Text('• ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Icon(FontAwesomeIcons.userPlus,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'addPatient'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
            Row(
              children: [
                const Text('• ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Icon(FontAwesomeIcons.plus,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'addToCare'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
            Row(
              children: [
                const Text('• ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Icon(FontAwesomeIcons.penClip,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'editPatientData'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
            Row(
              children: [
                const Text('• ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Icon(FontAwesomeIcons.list,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'patientDetails'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
