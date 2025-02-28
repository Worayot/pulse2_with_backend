import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MewsResultWidget extends StatelessWidget {
  final String mews;

  // Constructor
  const MewsResultWidget({super.key, required this.mews});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Process MEWs
    String nursing = "";
    int? MEWs = int.tryParse(mews);

    if (MEWs == null) {
      return const SizedBox(); // Return an empty widget if MEWs is not a valid integer
    }

    if (MEWs <= 1) {
      nursing = "nursingLow".tr();
    } else if (MEWs == 2) {
      nursing = "nursingLowMedium".tr();
    } else if (MEWs == 3) {
      nursing = "nursingMedium".tr();
    } else if (MEWs == 4) {
      nursing = "nursingMediumHigh".tr();
    } else if (MEWs >= 5) {
      nursing = "nursingHigh".tr();
    }

    return SizedBox(
      width: screenWidth * 0.8, // Adjust width dynamically
      child: Column(
        children: [
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  "${"latestMEWs".tr()} : ",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06, // Dynamic font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  mews,
                  style: TextStyle(
                    fontSize: screenWidth * 0.1, // Dynamic font size
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
              style:
                  TextStyle(fontSize: screenWidth * 0.045), // Dynamic font size
              textAlign: TextAlign.left,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
