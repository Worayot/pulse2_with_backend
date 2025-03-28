import 'package:flutter/material.dart';
import 'package:tuh_mews/utils/date_navigation.dart';
import 'package:tuh_mews/utils/swipable_table.dart';

class ReportWidget extends StatefulWidget {
  final double tableHeight;
  final String patientID;

  const ReportWidget({
    super.key,
    required this.tableHeight,
    required this.patientID,
  });

  @override
  _ReportWidgetState createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  late double _tableHeight;
  DateTime selectedDate = DateTime.now();

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

  @override
  void initState() {
    super.initState();
    _tableHeight = widget.tableHeight; // Initialize the height from the widget
  }

  @override
  Widget build(BuildContext context) {
    print(selectedDate);
    return Card(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          DateNavigation(onDateChanged: _updateSelectedDate),

          const SizedBox(height: 20),
          // Ensure SwipableTable rebuilds when selectedDate changes
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              key: ValueKey<DateTime>(selectedDate), // Use selectedDate as key
              height: _tableHeight,
              child: SwipableTable(
                date: selectedDate,
                patientID: widget.patientID,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
