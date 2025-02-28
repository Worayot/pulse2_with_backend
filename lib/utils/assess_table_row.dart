import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pulse/func/get_color.dart';
import 'package:pulse/utils/mews_forms.dart';
import 'package:pulse/utils/note_editor.dart';

class AssessTableRowWidget extends StatelessWidget {
  final Map<String, dynamic> combinedData;
  final String myUserID;
  // Constructor with required parameters
  const AssessTableRowWidget({
    super.key,
    required this.combinedData,
    required this.myUserID,
  });

  @override
  Widget build(BuildContext context) {
    // final String time = combinedData['formatted_time'].split(' ')[0];
    final String time = combinedData['formatted_time'];
    final dynamic MEWs = combinedData['mews'];
    // final String auditorID = combinedData['auditor'];
    // final String mewsID = combinedData['mews_id'];
    final String noteID = combinedData['note_id'];
    final String note = combinedData['note'];
    // final String auditorID = combinedData['auditor'];
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.16,
            height: screenHeight * 0.033,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                4,
              ), // Rounded corners (optional)
            ),
            child: Center(
              child: Text(
                '$time${"n".tr()}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(
                        0.25,
                      ), // Shadow color with opacity
                      offset: const Offset(
                        0.4,
                        0.4,
                      ), // Horizontal and vertical offset
                      blurRadius: 0.5, // Blur radius
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: screenWidth * 0.28,
            height: screenHeight * 0.033,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff3362CC), // Text color
                backgroundColor: const Color(0xffE0EAFF), // Background color
                shadowColor: Colors.transparent, // Removes shadow
                side: const BorderSide(
                  color: Color(0xff3362CC), // Border color
                  width: 1, // Border width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MEWsForms();
                  },
                );
              },
              child: Text(
                "assessScore".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            // padding: padding,
            width: screenWidth * 0.18,
            height: screenHeight * 0.033,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                4,
              ), // Rounded corners (optional)
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MEWS : ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(
                            0.25,
                          ), // Shadow color with opacity
                          offset: const Offset(
                            0.8,
                            0.8,
                          ), // Horizontal and vertical offset
                          blurRadius: 1, // Blur radius
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$MEWs',
                    style: TextStyle(
                      color: getColor(MEWs),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Shadow color with opacity
                          offset: const Offset(
                            0.8,
                            0.8,
                          ), // Horizontal and vertical offset
                          blurRadius: 1, // Blur radius
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: screenWidth * 0.18,
            height: screenHeight * 0.033,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff3362CC), // Text color
                backgroundColor: const Color(0xffE0EAFF), // Background color
                shadowColor: Colors.transparent, // Removes shadow
                side: const BorderSide(
                  color: Color(0xff3362CC), // Border color
                  width: 1, // Border width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NoteEditor(note: note, noteID: noteID);
                  },
                );
              },
              child: Text(
                "note".tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
