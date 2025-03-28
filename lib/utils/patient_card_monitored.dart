import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/func/get_color.dart';
import 'package:tuh_mews/utils/action_button.dart';
import 'package:tuh_mews/utils/circle_with_num.dart';
import 'package:tuh_mews/utils/assess_table_row.dart';
import 'package:tuh_mews/utils/mews_forms_instant.dart';
import 'package:tuh_mews/utils/time_manager.dart';
import 'package:tuh_mews/func/time_formatter.dart';
import 'package:timezone/timezone.dart' as tz;

class MonitoredPatientCard extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final VoidCallback onPop;
  const MonitoredPatientCard({
    super.key,
    required this.patientData,
    required this.onPop,
  });

  @override
  State<MonitoredPatientCard> createState() => _MonitoredPatientCardState();
}

class _MonitoredPatientCardState extends State<MonitoredPatientCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var patientData = widget.patientData;
    String patientID = patientData['patient_id'];
    String myUserID = patientData['user_id'];
    Map<String, dynamic> patientDetails = patientData['patient_details'];
    String fullname = patientDetails['fullname'];
    List<Map<String, dynamic>> dataRows = patientData['inspection_notes'];
    dataRows.sort((a, b) => a['time'].compareTo(b['time']));

    Size size = MediaQuery.of(context).size;
    int dataLength = dataRows.length;

    List<Map<String, dynamic>> combinedData = [];

    if (dataRows.isNotEmpty) {
      for (var map in dataRows) {
        // print(map);
        Timestamp timestamp = map['time'];
        DateTime dateTime = timestamp.toDate().toUtc();

        // Convert DateTime to Asia/Bangkok timezone
        final bangkokTimezone = tz.getLocation('Asia/Bangkok');
        var localDateTime = tz.TZDateTime.from(dateTime, bangkokTimezone);
        localDateTime = localDateTime.subtract(Duration(hours: 7));

        // Format the local DateTime
        String formattedTime = DateFormat('HH.mm').format(localDateTime);
        String timeDelta = timeDeltaFromNow(dateTime: localDateTime);

        combinedData.add({
          "formatted_time": '$formattedTime${'n'.tr()} ($timeDelta)',
          "mews": map['mews']['mews'] ?? '-',
          "is_assessed": map['mews']['is_assessed'],
          "mews_id": map['mews_id'],
          "note_id": map['note_id'],
          "note": map['text'] ?? '',
          "auditor": map['audit_by'],
        });
      }
    }

    // Get latest values
    String latestTime =
        combinedData.isNotEmpty ? combinedData.last["formatted_time"] : "-";

    String latestMews =
        combinedData.isNotEmpty ? combinedData.last["mews"].toString() : "-";

    // print(combinedData);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          // Expanded Content
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded; // Toggle state
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.only(top: 16),
                    height:
                        isExpanded
                            ? (size.height * 0.033 + 8) * dataLength + 96
                            : 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff98B1E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70),
                          if (isExpanded) ...[
                            Column(
                              children: List.generate(dataLength, (i) {
                                return AssessTableRowWidget(
                                  combinedData: combinedData[i],
                                  myUserID: myUserID,
                                  patientID: patientID,
                                  onPop: widget.onPop,
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Collapsed Header
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: const Color(0xffE0EAFF),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded; // Toggle state
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 12),
                        child: CircleWithNumber(
                          number: latestMews,
                          color: getColor(latestMews),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullname,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.04,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0.4, 0.4),
                                    blurRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "nextInspectionTime".tr(),
                              style: TextStyle(fontSize: size.width * 0.03),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              latestTime,
                              style: TextStyle(fontSize: size.width * 0.03),
                            ),
                          ],
                        ),
                      ),
                      buildActionButton(
                        FontAwesomeIcons.magnifyingGlassPlus,
                        () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return InstantMEWsForm(
                                patientID: patientID,
                                auditorID: myUserID,
                                onPop: widget.onPop,
                              );
                            },
                          );
                        },
                        Colors.white,
                        const Color(0xff3362CC),
                      ),
                      SizedBox(width: size.width * 0.017),
                      buildActionButton(
                        FontAwesomeIcons.solidClock,
                        () {
                          showTimeManager(
                            context: context,
                            screenWidth: size.width,
                            screenHeight: size.height,
                            auditorID: myUserID,
                            patientID: patientID,
                            onPop: widget.onPop,
                            patientName: fullname,
                          );
                        },
                        Colors.white,
                        const Color(0xff3362CC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 75,
            child: IgnorePointer(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('assess'.tr()),
                    isExpanded
                        ? Icon(Icons.expand_less)
                        : Icon(Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
