import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

void showNursing(BuildContext context, String MEWs) {
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
                buildNursingDetails(context, MEWs),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildNursingDetails(BuildContext context, String MEWs) {
  // Process MEWs
  String nursing = "";
  int? MEWs0 = int.tryParse(MEWs);
  if (MEWs0 == null) {
    nursing = "nursingInvalid".tr(); // Provide a fallback for invalid MEWs
  } else if (MEWs0 <= 1) {
    nursing = "nursingLow".tr();
  } else if (MEWs0 == 2) {
    nursing = "nursingLowMedium".tr();
  } else if (MEWs0 == 3) {
    nursing = "nursingMedium".tr();
  } else if (MEWs0 == 4) {
    nursing = "nursingMediumHigh".tr();
  } else if (MEWs0 >= 5) {
    nursing = "nursingHigh".tr();
  }

  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Row(children: [Text("MEWs : $MEWs", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))])),
          const Gap(4),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(nursing, style: TextStyle(fontSize: 18), textAlign: TextAlign.left, softWrap: true)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
