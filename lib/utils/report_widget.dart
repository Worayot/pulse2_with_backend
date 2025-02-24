import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pulse/utils/date_navigation.dart';
import 'package:pulse/utils/swipable_table.dart';

class ReportWidget extends StatelessWidget {
  final double tableHeight;
  const ReportWidget({super.key, required this.tableHeight});

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return Card(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const DateNavigation(),
          const SizedBox(height: 20),
          SizedBox(height: tableHeight, child: const SwipableTable())
        ],
      ),
    );
  }
}
