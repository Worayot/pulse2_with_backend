import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/models/note.dart';
import 'package:pulse/utils/note_adder.dart';

void showResultDialog({
  required BuildContext context,
  required int MEWs,
  required String noteID,
}) {
  List<dynamic> components = getComponent(MEWs);
  String nursing = components[0];
  String emoji = components[1];
  Color bgColor = components[2];
  String title = components[3];

  Size size = MediaQuery.of(context).size;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: size.height,
                color: bgColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "finishedCalculating".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "\t\t${"totalScore".tr()}: $MEWs",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "${"nursing".tr()}:",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    height: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                child: Text(
                                  nursing,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return NoteAdder(noteID: noteID);
                    },
                  );
                },
                icon: const Icon(
                  FontAwesomeIcons.solidPenToSquare,
                  color: Colors.white,
                ),
                label: Text(
                  'addNote'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF565656),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Emoji and Close Button go outside of SingleChildScrollView
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(opacity: 0.5, child: Image.asset(emoji)),
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

List<dynamic> getComponent(int MEWs) {
  // Process MEWs
  String nursing = "";
  String emoji;
  Color bgColor;
  String title = "";
  if (MEWs <= 1) {
    nursing = "nursingLow".tr();
    emoji = "assets/images/emojis/emoji_low.png";
    bgColor = const Color(0xffCEFF9F);
    title = "lowRisk".tr();
  } else if (MEWs == 2) {
    nursing = "nursingLowMedium".tr();
    emoji = "assets/images/emojis/emoji_midlow.png";
    bgColor = const Color(0xffFFF9AD);
    title = "lowRisk".tr();
  } else if (MEWs == 3) {
    nursing = "nursingMedium".tr();
    emoji = "assets/images/emojis/emoji_mid.png";
    title = "medRisk".tr();
    bgColor = const Color(0xffFFE897);
  } else if (MEWs == 4) {
    nursing = "nursingMediumHigh".tr();
    emoji = "assets/images/emojis/emoji_midhigh.png";
    bgColor = const Color(0xffFFD2B8);
    title = "medhighRisk".tr();
  } else if (MEWs >= 5) {
    nursing = "nursingHigh".tr();
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
