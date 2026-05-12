import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NursingComponent {
  final String nursing;
  final String emoji;
  final String title;
  final Color bgColor;

  NursingComponent({required this.nursing, required this.emoji, required this.title, required this.bgColor});

  static NursingComponent getComponent(int? mews) {
    if (mews == null) {
      return NursingComponent(nursing: "", emoji: "", title: "Error", bgColor: Colors.black);
    }

    String nursing = "";
    String emoji;
    Color bgColor;
    String title = "";
    if (mews <= 1) {
      nursing = "nursingLow";
      emoji = "assets/images/emojis/emoji_low.png";
      bgColor = const Color(0xffa0cf63);
      title = "lowRisk".tr();
    } else if (mews == 2) {
      nursing = "nursingLowMedium";
      emoji = "assets/images/emojis/emoji_midlow.png";
      bgColor = const Color(0xffffff55);
      title = "lowRisk";
    } else if (mews == 3) {
      nursing = "nursingMedium";
      emoji = "assets/images/emojis/emoji_mid.png";
      title = "medRisk".tr();
      bgColor = const Color(0xffea9b57);
    } else if (mews == 4) {
      nursing = "nursingMediumHigh";
      emoji = "assets/images/emojis/emoji_midhigh.png";
      bgColor = const Color(0xffea9b57);
      title = "medhighRisk".tr();
    } else if (mews >= 5) {
      nursing = "nursingHigh";
      emoji = "assets/images/emojis/emoji_high.png";
      bgColor = const Color(0xffea3323);
      title = "highRisk".tr();
    } else {
      nursing = "Error";
      emoji = "assets/images/emojis/emoji_high.png";
      bgColor = const Color.fromARGB(255, 255, 51, 211);
    }

    return NursingComponent(nursing: nursing, emoji: emoji, title: title, bgColor: bgColor);
  }

  static Color getColor(String num) {
    return getComponent(int.tryParse(num)).bgColor;
  }
}
