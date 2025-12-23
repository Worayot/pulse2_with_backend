import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/func/get_color.dart';
import 'package:tuh_mews/models/monitored_patient/card_model.dart';
import 'package:tuh_mews/utils/action_button.dart';
import 'package:tuh_mews/utils/circle_with_num.dart';
import 'package:tuh_mews/utils/assess_table_row.dart';
import 'package:tuh_mews/utils/mews_forms_instant.dart';
import 'package:tuh_mews/utils/time_manager.dart';
import 'package:timezone/timezone.dart' as tz;

class MonitoredPatientCard extends StatefulWidget {
  final PatientModel patient;
  final VoidCallback onPop;

  const MonitoredPatientCard({super.key, required this.patient, required this.onPop});

  @override
  State<MonitoredPatientCard> createState() => _MonitoredPatientCardState();
}

class _MonitoredPatientCardState extends State<MonitoredPatientCard> {
  String _latestTimeText = "";
  String _countdownText = "";
  Timer? _timer;

  // You can create a small UI model for this list if you want,
  // but keeping Map<String, dynamic> for the specific UI row state is okay for now.
  List<Map<String, dynamic>> _processedUIRows = [];
  DateTime? _nearestFutureTime;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _processInspectionData();
    _startNearestTimeCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _processInspectionData() {
    // 1. Get notes from the Model
    List<InspectionNoteModel> notes = widget.patient.inspectionNotes;

    // 2. Sort using Model DateTime
    notes.sort((a, b) => a.time.compareTo(b.time));

    // 3. Process into UI-ready data
    final bangkokTimezone = tz.getLocation('Asia/Bangkok');

    _processedUIRows =
        notes.map((noteModel) {
          // Convert Model DateTime (UTC/Local) to Specific Timezone
          DateTime dateTimeUtc = noteModel.time.toUtc();
          var localDateTime = tz.TZDateTime.from(dateTimeUtc, bangkokTimezone);

          String formattedTime = DateFormat('HH.mm').format(localDateTime);
          String timeFull = DateFormat('yyyy-MM-dd HH:mm:ss').format(localDateTime);

          return {
            "formatted_time": '$formattedTime${'n'.tr()}',
            "mews": noteModel.mewsScore,
            "is_assessed": noteModel.isAssessed,
            "mews_id": noteModel.mewsId,
            "note_id": noteModel.noteId,
            "note": noteModel.noteText,
            "auditor": noteModel.auditor,
            "time": timeFull,
            "local_date_time": localDateTime,
          };
        }).toList();

    // 4. Calculate Nearest Future Time
    DateTime nowUtc = DateTime.now().toUtc();
    final nowLocal = tz.TZDateTime.from(nowUtc, bangkokTimezone);

    List<DateTime> futureTimes = _processedUIRows.map((item) => item['local_date_time'] as DateTime).where((t) => t.isAfter(nowLocal)).toList();

    futureTimes.sort((a, b) => a.compareTo(b));

    _nearestFutureTime = futureTimes.isNotEmpty ? futureTimes.first : null;
    _latestTimeText = _nearestFutureTime != null ? DateFormat('HH.mm.ss').format(_nearestFutureTime!) + 'n'.tr() : "-";
  }

  void _startNearestTimeCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nearestFutureTime != null) {
        final bangkokTimezone = tz.getLocation('Asia/Bangkok');
        final nowLocal = tz.TZDateTime.from(DateTime.now().toUtc(), bangkokTimezone);
        final nearestFutureTimeLocal = tz.TZDateTime.from(_nearestFutureTime!, bangkokTimezone);

        if (nearestFutureTimeLocal.isAfter(nowLocal)) {
          final difference = nearestFutureTimeLocal.difference(nowLocal);
          // ... formatting logic same as before ...
          final days = difference.inDays;
          final hours = difference.inHours % 24;
          final minutes = difference.inMinutes % 60;
          final seconds = difference.inSeconds % 60;

          if (mounted) {
            setState(() {
              _countdownText = " (${days > 0 ? '$days days ' : ''}${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')})";
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _countdownText = " ";
            });
            _processInspectionData(); // Refresh data
            _startNearestTimeCountdown(); // Restart timer
          }
        }
      } else {
        if (mounted)
          setState(() {
            _countdownText = " ";
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access data directly from the Model
    String patientID = widget.patient.patientId;
    String myUserID = widget.patient.userId;
    String fullname = widget.patient.fullname;

    Size size = MediaQuery.of(context).size;
    int dataLength = _processedUIRows.length;

    // Logic to find latest score
    List<String> scores = _processedUIRows.map((item) => item["mews"].toString()).toList();
    int latestIndex = scores.lastIndexWhere((score) => int.tryParse(score) != null);
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
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.only(top: 16),
                    height: isExpanded ? (size.height * 0.033 + 8) * dataLength + 101 : 101,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xff98B1E8), borderRadius: BorderRadius.circular(16)),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 75),
                          if (isExpanded)
                            Column(
                              children: List.generate(dataLength, (i) {
                                return AssessTableRowWidget(combinedData: _processedUIRows[i], myUserID: myUserID, patientID: patientID, onPop: widget.onPop);
                              }),
                            ),
                          const SizedBox(height: 10),
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
            decoration: BoxDecoration(color: const Color(0xffE0EAFF), borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 4.0, right: 12), child: CircleWithNumber(number: latestMews, color: getColor(latestMews))),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullname, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("nextInspectionTime".tr(), style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 16),
                                children: [TextSpan(text: _latestTimeText), TextSpan(text: _countdownText, style: TextStyle(fontSize: 14, color: Colors.grey[600]))],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ... Action Buttons (same as before) ...
                      buildActionButton(
                        FontAwesomeIcons.magnifyingGlassPlus,
                        () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return InstantMEWsForm(patientID: patientID, auditorID: myUserID, onPop: widget.onPop);
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
              child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('assess'.tr()), Icon(isExpanded ? Icons.expand_less : Icons.expand_more)])),
            ),
          ),
        ],
      ),
    );
  }
}
