import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/utils/note_viewer.dart';

class PatientReportTable extends StatefulWidget {
  final DateTime date;
  final String patientID;

  const PatientReportTable({super.key, required this.date, required this.patientID});

  @override
  _PatientReportTableState createState() => _PatientReportTableState();
}

class _PatientReportTableState extends State<PatientReportTable> {
  bool _isLoading = true;
  var patientData = {};
  List<Map<String, dynamic>> _fullReports = [];
  List<List<String>> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchPatientReport(widget.patientID);
  }

  @override
  void didUpdateWidget(covariant PatientReportTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.date != widget.date) {
      fetchPatientReport(widget.patientID);
    }
  }

  void fetchPatientReport(String patientId) async {
    setState(() {
      _isLoading = true;
    });

    var reportData = await PatientService().getPatientReport(patientId: patientId, date: widget.date);

    if (reportData != null) {
      setState(() {
        patientData = reportData;
        _fullReports = (patientData['full_reports'] ?? []).cast<Map<String, dynamic>>();

        _processReports();
      });
    } else {
      debugPrint('Failed to fetch patient report');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _processReports() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    tableData =
        _fullReports.map((report) {
          final DateTime assessedTime = report['assessed_time'];

          return [
            formatter.format(assessedTime),
            (report['consciousness'] ?? '-').toString(),
            (report['temperature'] ?? '-').toString(),
            (report['heart_rate'] ?? '-').toString(),
            (report['respiratory_rate'] ?? '-').toString(),
            (report['blood_pressure'] ?? '-').toString(),
            (report['spo2'] ?? '-').toString(),
            (report['urine'] ?? '-').toString(),
            (report['mews'] ?? '-').toString(),
            (report['cvp'] ?? '-').toString(),
          ];
        }).toList();
  }

  Future<String> fetchNoteData(String reportID) async {
    try {
      var noteDoc = await FirebaseFirestore.instance.collection('inspection_notes').doc(reportID).get();

      if (noteDoc.exists) {
        var noteData = noteDoc.data()!;
        String noteText = noteData['text'] ?? '';
        return noteText;
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  Widget _buildButtonCell({required int index, required BuildContext context, required String reportID}) {
    return FutureBuilder<String>(
      future: fetchNoteData(reportID),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else {
          final noteText = snapshot.data;
          if (noteText != null && noteText.trim().isNotEmpty && noteText.trim() != '-') {
            return Container(
              height: 35,
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.solidBookmark, color: Color(0xffFCAD00)),
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
    if (_isLoading) {
      return SizedBox(
        child: Center(
          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)), padding: EdgeInsets.all(4), child: CircularProgressIndicator()),
        ),
      );
    }
    if (_fullReports.isEmpty) {
      return SizedBox(
        child: Center(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(4),
            child: Text("noDataFound".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(2),
      color: Colors.white54,
      child: SingleChildScrollView(
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
                  decoration: BoxDecoration(color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white),
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
                    _buildButtonCell(index: index, context: context, reportID: reportID),
                  ],
                );
              }),
            ],
          ),
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
      decoration: BoxDecoration(color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white),
      child: Text(text),
    );
  }
}
