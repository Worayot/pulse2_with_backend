import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/utils/note_viewer.dart';
import 'package:intl/intl.dart';
import 'package:tuh_mews/utils/report_widget.dart';

class SwipableTable extends StatefulWidget {
  final DateTime date;
  final String patientID;

  const SwipableTable({super.key, required this.date, required this.patientID});

  @override
  _SwipableTableState createState() => _SwipableTableState();
}

class _SwipableTableState extends State<SwipableTable> {
  var patientData = {};
  List<Map<String, dynamic>> _fullReports = [];
  List<List<String>> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchPatientReport(widget.patientID);
  }

  void fetchPatientReport(String patientId) async {
    var reportData = await PatientService().getPatientReport(patientId);

    if (reportData != null) {
      setState(() {
        patientData = reportData;
        _fullReports =
            (patientData['full_reports'] ?? [])
                .cast<Map<String, dynamic>>(); // Ensure it's a list of maps
        _sortFullReportsByTime();
        filterDataByDate(widget.date);
      });
    } else {
      print('Failed to fetch patient report');
    }
  }

  void _sortFullReportsByTime() {
    _fullReports.sort((a, b) {
      DateTime timeA = DateTime.parse(
        a['time'] ?? '',
      ).toUtc().add(const Duration(hours: 7));
      DateTime timeB = DateTime.parse(
        b['time'] ?? '',
      ).toUtc().add(const Duration(hours: 7));
      return timeA.compareTo(timeB);
    });
  }

  void filterDataByDate(DateTime selectedDate) {
    setState(() {
      tableData =
          _fullReports
              .where((report) {
                DateTime reportDate = DateTime.parse(
                  report['time'] ?? '',
                ).toUtc().add(const Duration(hours: 7));
                return reportDate.year == selectedDate.year &&
                    reportDate.month == selectedDate.month &&
                    reportDate.day == selectedDate.day;
              })
              .map((report) {
                DateTime reportDate = DateTime.parse(
                  report['time'] ?? '',
                ).toUtc().add(const Duration(hours: 7));
                List<String> timeParts = reportDate.toString().split(' ');

                return [
                  ('${timeParts[0]} ${timeParts[1].split('.')[0]}').toString(),
                  (report['consciousness'] ?? '').toString(),
                  (report['temperature'] ?? '').toString(),
                  (report['heart_rate'] ?? '').toString(),
                  (report['respiratory_rate'] ?? '').toString(),
                  (report['blood_pressure'] ?? '').toString(),
                  (report['spo2'] ?? '').toString(),
                  (report['urine'] ?? '').toString(),
                  (report['mews'] ?? '').toString(),
                  (report['cvp'] ?? '').toString(),
                ];
              })
              .toList();
    });
  }

  Future<String> fetchNoteData(String reportID) async {
    try {
      var noteDoc =
          await FirebaseFirestore.instance
              .collection('inspection_notes')
              .doc(reportID)
              .get();

      if (noteDoc.exists) {
        var noteData = noteDoc.data()!;
        String noteText = noteData['text'] ?? '';
        return noteText;
      }
      return "";
    } catch (e) {
      print("Error fetching note data: $e");
      return "";
    }
  }

  Widget _buildButtonCell({
    required int index,
    required BuildContext context,
    required String reportID,
  }) {
    return FutureBuilder<String>(
      future: fetchNoteData(reportID),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Or a small loading indicator
        } else if (snapshot.hasError) {
          return const SizedBox.shrink(); // Or an error indicator
        } else {
          final noteText = snapshot.data;
          if (noteText != null &&
              noteText.trim().isNotEmpty &&
              noteText.trim() != '-') {
            return Container(
              height: 35,
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.solidBookmark,
                  color: Color(0xffFCAD00),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return NoteViewer(reportID: reportID);
                    },
                  );
                },
              ),
            );
          } else {
            return const SizedBox.shrink(); // Don't render the button
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          border: const TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
            top: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
          ),
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(60),
            3: FixedColumnWidth(60),
            4: FixedColumnWidth(60),
            5: FixedColumnWidth(80),
            6: FixedColumnWidth(100),
            7: FixedColumnWidth(60),
            8: FixedColumnWidth(120),
            9: FixedColumnWidth(100),
            10: FixedColumnWidth(120),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFC6D8FF)),
              children: [
                _buildHeaderCell('time'.tr()),
                _buildHeaderCell('C'),
                _buildHeaderCell('T'),
                _buildHeaderCell('P'),
                _buildHeaderCell('R'),
                _buildHeaderCell('BP'),
                _buildHeaderCell('O2, Sat'),
                _buildHeaderCell('Urine'),
                _buildHeaderCell('MEWs Score'),
                _buildHeaderCell('CVP'),
                _buildHeaderCell('Management'),
              ],
            ),
            ...List.generate(tableData.length, (index) {
              final reportID = _fullReports[index]['report_id'] ?? '';
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white,
                ),
                children: [
                  _buildContainerCell(tableData[index][0], index),
                  _buildContainerCell(tableData[index][1], index),
                  _buildContainerCell(tableData[index][2], index),
                  _buildContainerCell(tableData[index][3], index),
                  _buildContainerCell(tableData[index][4], index),
                  _buildContainerCell(tableData[index][5], index),
                  _buildContainerCell(tableData[index][6], index),
                  _buildContainerCell(tableData[index][7], index),
                  _buildContainerCell(tableData[index][8], index),
                  _buildContainerCell(tableData[index][9], index),
                  _buildButtonCell(
                    index: index,
                    context: context,
                    reportID: reportID,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      height: 35,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildContainerCell(String text, int index) {
    return Container(
      height: 35,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white,
      ),
      child: Text(text),
    );
  }
}
