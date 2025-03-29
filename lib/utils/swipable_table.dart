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
      });

      // Filter the data based on the selected date
      filterDataByDate(widget.date);
    } else {
      print('Failed to fetch patient report');
    }
  }

  void filterDataByDate(DateTime selectedDate) {
    if (patientData.isNotEmpty) {
      final fullReports = patientData['full_reports'] ?? [];

      // print(fullReports);

      setState(() {
        tableData =
            List.generate(fullReports.length, (index) {
                  final report = fullReports[index];

                  // Ensure the report date matches the selected date
                  // DateTime reportDate = DateTime.parse(
                  //   report['time'] ?? '',
                  // ); // Use 'time' field for the report date

                  DateTime reportDate = DateTime.parse(
                    report['time'] ?? '',
                  ).toUtc().add(Duration(hours: 7));

                  // print(report['time']);

                  // print(reportDate);

                  // reportDate = reportDate.subtract(Duration(days: 1));

                  // print(reportDate.day);
                  // print(selectedDate.day);

                  // Only include rows where the date matches the selected date
                  if (reportDate.year == selectedDate.year &&
                      reportDate.month == selectedDate.month &&
                      reportDate.day == selectedDate.day) {
                    List<String> timeParts = reportDate.toString().split(' ');
                    return [
                      ('${timeParts[0]} ${timeParts[1].split('.')[0]}' ?? 'N?A')
                          .toString(),
                      (report['consciousness'] ?? 'Conscious')
                          .toString(), // Use 'consciousness' for 'C'
                      (report['temperature'] ?? '37.5')
                          .toString(), // Use 'temperature' for 'T'
                      (report['heart_rate'] ?? '120')
                          .toString(), // Use 'heart_rate' for 'P'
                      (report['respiratory_rate'] ?? '18')
                          .toString(), // Use 'respiratory_rate' for 'R'
                      (report['blood_pressure'] ?? '120/80')
                          .toString(), // Use 'blood_pressure' for 'BP'
                      (report['spo2'] ?? '98%, 95')
                          .toString(), // Use 'spo2' for 'O2, Sat'
                      (report['urine'] ?? '0.5L')
                          .toString(), // Use 'urine' for 'Urine'
                      (report['mews'] ?? '3')
                          .toString(), // Use 'mews' for 'MEWs Score'
                      (report['cvp'] ?? '14').toString(), // Use 'cvp' for 'CVP'
                    ]; // Explicit cast to List<String>
                  } else {
                    return []; // Skip this entry if the date doesn't match
                  }
                })
                .where((row) => row.isNotEmpty)
                .toList()
                .cast<List<String>>(); // Cast to List<List<String>>
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Horizontal scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Vertical scrolling
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
            0: FixedColumnWidth(180), // Time column width
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
            // Header Row
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
            // Data Rows
            ...List.generate(tableData.length, (index) {
              final reportID =
                  patientData['full_reports'][index]['report_id'] ?? '';
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

  // Builds the header cell with fixed height
  Widget _buildHeaderCell(String text) {
    return Container(
      height: 35, // Reduced height for header cells to lower the row space
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced padding
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Builds the content cell with fixed height, shadow, and reduced padding
  Widget _buildContainerCell(String text, int index) {
    return Container(
      height: 35, // Reduced height for content cells
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced padding
      decoration: BoxDecoration(
        color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white,
      ),
      child: Text(text),
    );
  }

  // Builds the button cell with fixed height and reduced padding
  Widget _buildButtonCell({
    required int index,
    required BuildContext context,

    required String reportID,
  }) {
    return Container(
      height: 35, // Reduced height for button cell
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
  }
}
