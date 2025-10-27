import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// Removed unused FontAwesome and NoteAdder imports

void showGeneralResultDialog({required BuildContext context, required int MEWs}) {
  List<dynamic> components = getComponent(MEWs);
  String nursing = components[0];
  String emoji = components[1];
  Color bgColor = components[2];
  String title = components[3];

  // Removed unused 'size' variable

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: Colors.transparent,
        // Added clipBehavior and shape to match target
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                // Removed fixed height
                width: double.infinity,
                color: bgColor,
                // Changed to a Column to use Expanded
                child: Column(
                  children: [
                    // --- 1. THE FIXED (NON-SCROLLING) PART ---
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

                    // --- 2. THE SCROLLABLE PART ---
                    // Added Expanded and SingleChildScrollView
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              // Removed useless SizedBox wrapper
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12.0)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  // Added crossAxisAlignment
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    Text("${"nursing".tr()}:", style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold, height: 0.5)),
                                    const SizedBox(height: 10),
                                    Text(nursing, style: const TextStyle(fontSize: 16, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                            // Added bottom padding for scrolling
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(bottom: 0, right: 0, child: IgnorePointer(child: Opacity(opacity: 0.5, child: Image.asset(emoji)))),
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

// getComponent function (no changes)
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
