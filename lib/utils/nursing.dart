import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void showNursing(BuildContext context, String MEWs) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            title: Row(
              children: [
                Text(
                  "nursing".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            contentPadding: EdgeInsets.only(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: screenHeight * 0.02,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Process MEWs
  String nursing = "";
  int? _MEWs = int.tryParse(MEWs);
  if (_MEWs == null) {
    nursing = "nursingInvalid".tr(); // Provide a fallback for invalid MEWs
  } else if (_MEWs <= 1) {
    nursing = "nursingLow".tr();
  } else if (_MEWs == 2) {
    nursing = "nursingLowMedium".tr();
  } else if (_MEWs == 3) {
    nursing = "nursingMedium".tr();
  } else if (_MEWs == 4) {
    nursing = "nursingMediumHigh".tr();
  } else if (_MEWs >= 5) {
    nursing = "nursingHigh".tr();
  }

  return SizedBox(
    width: screenWidth * 0.7,
    child: Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        Row(
          children: [
            Text(
              "${"latestMEWs".tr()} : ",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: Text(
                MEWs,
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
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
            style: TextStyle(fontSize: screenWidth * 0.045),
            textAlign: TextAlign.left,
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}
