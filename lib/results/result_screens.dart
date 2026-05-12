import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/helpers/app_localized_rich_text.dart';
import 'package:tuh_mews/utils/note_adder.dart'; // Assuming this is correct

void showResultDialog({required int MEWs, required String noteID, required VoidCallback onPop, required NavigatorState navigator}) {
  List<dynamic> components = getComponent(MEWs);
  String nursing = components[0];

  Widget nursingWidget = AppLocalizedRichText(
    translationKey: nursing,
    style: const TextStyle(fontSize: 18, color: Colors.black),
    boldStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
  );

  String emoji = components[1];
  Color bgColor = components[2];
  String title = components[3];

  showDialog(
    context: navigator.context,
    builder: (context) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: bgColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Positioned(bottom: 0, right: 0, child: IgnorePointer(child: Opacity(opacity: 0.5, child: Image.asset(emoji)))),

            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: Text("finishedCalculating".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("\t\t${"totalScore".tr()}: $MEWs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(12.0)),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Gap(16),

                          Text("${"nursing".tr()} :", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Gap(12),

                          Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.only(right: 12.0), child: nursingWidget)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Align(
                    alignment: AlignmentGeometry.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NoteAdder(noteID: noteID, onPop: onPop);
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF565656), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.solidPenToSquare, color: Colors.white, size: 16),
                            const Gap(8),
                            Text('addNote'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close, color: Colors.black, size: 30),
              ),
            ),
          ],
        ),
      );
    },
  );
}

List<dynamic> getComponent(int mews) {
  // Process mews
  String nursing = "";
  String emoji;
  Color bgColor;
  String title = "";
  if (mews <= 1) {
    nursing = "nursingLow";
    emoji = "assets/images/emojis/emoji_low.png";
    bgColor = const Color(0xffCEFF9F);
    title = "lowRisk".tr();
  } else if (mews == 2) {
    nursing = "nursingLowMedium";
    emoji = "assets/images/emojis/emoji_midlow.png";
    bgColor = const Color(0xffFFF9AD);
    title = "lowRisk";
  } else if (mews == 3) {
    nursing = "nursingMedium";
    emoji = "assets/images/emojis/emoji_mid.png";
    title = "medRisk".tr();
    bgColor = const Color(0xffFFE897);
  } else if (mews == 4) {
    nursing = "nursingMediumHigh";
    emoji = "assets/images/emojis/emoji_midhigh.png";
    bgColor = const Color(0xffFFD2B8);
    title = "medhighRisk".tr();
  } else if (mews >= 5) {
    nursing = "nursingHigh";
    emoji = "assets/images/emojis/emoji_high.png";
    bgColor = const Color(0xffFFBE99);
    title = "highRisk".tr();
  } else {
    nursing = "Error";
    emoji = "assets/images/emojis/emoji_high.png";
    bgColor = const Color.fromARGB(255, 255, 51, 211);
  }

  return [nursing, emoji, bgColor, title];
}
