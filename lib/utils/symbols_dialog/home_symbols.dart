import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget homeSymbols() {
  return Container(
    // width: 400,
    // constraints: const BoxConstraints(
    //   maxHeight: 130,
    // ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                const Icon(FontAwesomeIcons.plus,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'addToWatchList'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
            Row(
              children: [
                const Icon(FontAwesomeIcons.clipboardList,
                    size: 16, color: Color(0xff3362CC)),
                Text('  ${'observerRecords'.tr()}',
                    style: const TextStyle(fontSize: 16))
              ],
            ),
            Row(
              children: [
                const Icon(FontAwesomeIcons.minus, size: 16, color: Colors.red),
                Flexible(
                  child: Text(
                    '  ${'deletePatientInCare'.tr()}',
                    style: const TextStyle(fontSize: 16),
                    softWrap: true, // Allows text to wrap to a new line
                    overflow: TextOverflow
                        .visible, // Ensures the text isn't truncated
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
