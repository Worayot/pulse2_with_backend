import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MewsResultWidget extends StatelessWidget {
  final String mews;

  // Constructor
  const MewsResultWidget({Key? key, required this.mews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth * 0.05;

    String nursing = "";
    final int? parsedMews = int.tryParse(mews);

    if (parsedMews == null) {
      return const SizedBox();
    }

    if (parsedMews <= 1) {
      nursing = "nursingLow".tr();
    } else if (parsedMews == 2) {
      nursing = "nursingLowMedium".tr();
    } else if (parsedMews == 3) {
      nursing = "nursingMedium".tr();
    } else if (parsedMews == 4) {
      nursing = "nursingMediumHigh".tr();
    } else if (parsedMews >= 5) {
      nursing = "nursingHigh".tr();
    }

    return SizedBox(
      width: screenWidth * 0.7,
      child: Column(
        children: [
          SizedBox(height: screenWidth * 0.05),
          Row(
            children: [
              Text(
                "${"latestMEWs".tr()} : ",
                style: TextStyle(
                  fontSize: baseFontSize * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                child: Text(
                  mews,
                  style: TextStyle(
                    fontSize: baseFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              nursing,
              style: TextStyle(
                fontSize: baseFontSize * 0.6,
              ),
              textAlign: TextAlign.left,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
