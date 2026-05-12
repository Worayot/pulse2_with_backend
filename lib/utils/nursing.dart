import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/helpers/app_localized_rich_text.dart';

void showNursing(BuildContext context, String mews) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: const Color(0xffE0EAFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Row
                Row(
                  children: [
                    const Gap(8),
                    Text("nursing".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close, color: Colors.black, size: 18),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),

                const Gap(4),

                // Content
                buildNursingDetails(context, mews),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildNursingDetails(BuildContext context, String mews) {
  // Process MEWs
  String nursing = "";
  int? mewScore = int.tryParse(mews);
  if (mewScore == null) {
    nursing = "";
  } else if (mewScore <= 1) {
    nursing = "nursingLow";
  } else if (mewScore == 2) {
    nursing = "nursingLowMedium";
  } else if (mewScore == 3) {
    nursing = "nursingMedium";
  } else if (mewScore == 4) {
    nursing = "nursingMediumHigh";
  } else if (mewScore >= 5) {
    nursing = "nursingHigh";
  }

  Widget nursingWidget = AppLocalizedRichText(
    translationKey: nursing,
    style: const TextStyle(fontSize: 18, color: Colors.black),
    boldStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
  );

  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Row(children: [Text("MEWs : $mews", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))])),
          const Gap(4),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(child: Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.only(right: 12), child: nursingWidget))),
            ),
          ),
        ],
      ),
    ),
  );
}
