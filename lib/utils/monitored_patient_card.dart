import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/func/get_color.dart';
import 'package:pulse/utils/action_button.dart';
import 'package:pulse/utils/circle_with_num.dart';
import 'package:pulse/utils/assess_table_row.dart';
import 'package:pulse/utils/time_manager.dart';
import 'package:pulse/func/time_formatter.dart';

class MonitoredPatientCard extends StatefulWidget {
  final Map<String, dynamic> patientData;
  const MonitoredPatientCard({super.key, required this.patientData});

  @override
  State<MonitoredPatientCard> createState() => _MonitoredPatientCardState();
}

class _MonitoredPatientCardState extends State<MonitoredPatientCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var patientData = widget.patientData;
    String patientID = patientData['patient_id'];
    String userID = patientData['user_id'];
    Map<String, dynamic> patientDetails = patientData['patient_details'];
    String gender = patientDetails['gender'];
    String bedNumber = patientDetails['bed_number'];
    String ward = patientDetails['ward'];
    String age = patientDetails['age'];
    String hn = patientDetails['hospital_number'];
    String fullname = patientDetails['fullname'];
    List<Map<String, dynamic>> dataRows = patientData['inspection_notes'];
    dataRows.sort((a, b) => a['time'].compareTo(b['time']));

    Size size = MediaQuery.of(context).size;
    int dataLength = dataRows.length;

    String latestTime = '-';
    String latestMews = '-';

    List<String> times = [];
    List<dynamic> previousMEWs = [];

    if (dataRows.isNotEmpty) {
      print(dataRows);
      String formattedTime = '';
      for (var map in dataRows) {
        Timestamp timestamp = map['time'];
        DateTime dateTime = timestamp.toDate();
        formattedTime = DateFormat('HH.mm').format(dateTime);
        String timeDelta = timeDeltaFromNow(dateTime: dateTime);
        times.add('$formattedTime${'n'.tr()} ($timeDelta)');
      }

      for (int i = 0; i < dataLength; i++) {
        previousMEWs.add(dataRows[i]['mews']['mews']);
      }
      latestMews = previousMEWs.last;
      latestTime = times.last;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: [
          // Expanded Content
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Match the container's radius
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
                        mainAxisSize:
                            MainAxisSize.min, // Adjust height dynamically
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 70,
                          ), // Static height for header
                          if (isExpanded) ...[
                            Column(
                              children: List.generate(dataLength, (i) {
                                // return Text("temp");
                                return TableRowWidget(
                                  MEWs: previousMEWs[i],
                                  time: '${times[i].split(' ')[0]}${'n'.tr()}',
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
                        FontAwesomeIcons.solidClock,
                        () {
                          showTimeManager(context, size.width, size.height);
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
        ],
      ),
    );
  }
}
