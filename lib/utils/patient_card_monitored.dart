import 'dart:async';

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
  String _latestTimeText = "";
  String _countdownText = "";
  Timer? _timer;
  List<Map<String, dynamic>> _processedData = [];
  DateTime? _nearestFutureTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _processInspectionData();
    _startNearestTimeCountdown();
  }

  void _processInspectionData() {
    var patientData = widget.patientData;
    List<Map<String, dynamic>> dataRows = patientData['inspection_notes'];
    dataRows.sort(
      (a, b) => (a['time'] as Timestamp).compareTo(b['time'] as Timestamp),
    );

    _processedData =
        dataRows.map((map) {
          Timestamp timestamp = map['time'];
          DateTime dateTimeUtc = timestamp.toDate().toUtc();
          final bangkokTimezone = tz.getLocation('Asia/Bangkok');
          var localDateTime = tz.TZDateTime.from(dateTimeUtc, bangkokTimezone);
          // String formattedTimeShort = DateFormat('HH.mm').format(localDateTime);
          String formattedTime = DateFormat('HH.mm').format(localDateTime);
          // String timeDelta = timeDeltaFromNow(dateTime: localDateTime);
          String timeFull = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(localDateTime);

          return {
            // "formatted_time_short":
            //     '$formattedTimeShort${'n'.tr()} ($timeDelta)',
            "formatted_time": '$formattedTime${'n'.tr()}',
            "mews": map['mews']['mews'] ?? '-',
            "is_assessed": map['mews']['is_assessed'],
            "mews_id": map['mews_id'],
            "note_id": map['note_id'],
            "note": map['text'] ?? '',
            "auditor": map['audit_by'],
            "time": timeFull,
            "local_date_time": localDateTime,
          };
        }).toList();

    DateTime nowUtc = DateTime.now().toUtc();
    final bangkokTimezone = tz.getLocation('Asia/Bangkok');
    final nowLocal = tz.TZDateTime.from(nowUtc, bangkokTimezone);

    List<DateTime> futureTimes =
        _processedData
            .map((item) => item['local_date_time'] as DateTime)
            .where((t) => t.isAfter(nowLocal))
            .toList();
    futureTimes.sort((a, b) => a.compareTo(b));

    _nearestFutureTime = futureTimes.isNotEmpty ? futureTimes.first : null;
    _latestTimeText =
        _nearestFutureTime != null
            ? DateFormat('HH.mm.ss').format(_nearestFutureTime!) + 'n'.tr()
            : "-";
  }

  void _startNearestTimeCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nearestFutureTime != null) {
        final nowUtc = DateTime.now().toUtc();
        final bangkokTimezone = tz.getLocation('Asia/Bangkok');
        final nowLocal = tz.TZDateTime.from(nowUtc, bangkokTimezone);
        final nearestFutureTimeLocal = tz.TZDateTime.from(
          _nearestFutureTime!,
          bangkokTimezone,
        );

        if (nearestFutureTimeLocal.isAfter(nowLocal)) {
          final difference = nearestFutureTimeLocal.difference(nowLocal);
          final days = difference.inDays;
          final hours = difference.inHours % 24;
          final minutes = difference.inMinutes % 60;
          final seconds = difference.inSeconds % 60;
          setState(() {
            _countdownText =
                " (${days > 0 ? '$days days ' : ''}${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')})";
          });
        } else {
          setState(() {
            _countdownText = " ";
          });
          _processInspectionData();
          _startNearestTimeCountdown();
        }
      } else {
        setState(() {
          _countdownText = " ";
        });
      }
    });
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var patientData = widget.patientData;
    String patientID = patientData['patient_id'];
    String myUserID = patientData['user_id'];
    Map<String, dynamic> patientDetails = patientData['patient_details'];
    String fullname = patientDetails['fullname'];

    Size size = MediaQuery.of(context).size;
    int dataLength = _processedData.length;

    List<String> scores =
        _processedData.map((item) => item["mews"].toString()).toList();

    int latestIndex = scores.lastIndexWhere(
      (score) => int.tryParse(score) != null,
    );

    String latestMews = latestIndex != -1 ? scores[latestIndex] : "-";

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
                      isExpanded = !isExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.only(top: 16),
                    height:
                        isExpanded
                            ? (size.height * 0.033 + 8) * dataLength + 101
                            : 101,
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
                          const SizedBox(height: 75),
                          if (isExpanded) ...[
                            Column(
                              children: List.generate(dataLength, (i) {
                                return AssessTableRowWidget(
                                  combinedData: _processedData[i],
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
                      isExpanded = !isExpanded;
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
                                fontSize: 16,
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
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 16),
                                children: [
                                  TextSpan(text: _latestTimeText),
                                  TextSpan(
                                    text: _countdownText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
            top: 85,
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
