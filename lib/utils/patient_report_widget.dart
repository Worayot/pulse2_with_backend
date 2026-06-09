import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/utils/patient_report_date_switcher.dart';
import 'package:tuh_mews/utils/patient_report_table.dart';

class PatientReportWidget extends StatefulWidget {
  final double tableHeight;
  final String patientID;

  const PatientReportWidget({super.key, required this.tableHeight, required this.patientID});

  @override
  _PatientReportWidgetState createState() => _PatientReportWidgetState();
}

class _PatientReportWidgetState extends State<PatientReportWidget> {
  late double _tableHeight;
  DateTime selectedDate = DateTime.now();

  void _updateSelectedDate(DateTime newDate) {
    debugPrint("Set to $newDate");
    setState(() {
      selectedDate = newDate;
    });
  }

  @override
  void initState() {
    super.initState();
    _tableHeight = widget.tableHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(20),
        PatientReportDateSwitcher(onDateChanged: _updateSelectedDate, selectedDay: selectedDate),
        const Gap(20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(height: _tableHeight, child: PatientReportTable(date: selectedDate, patientID: widget.patientID)),
        ),
      ],
    );
  }
}
