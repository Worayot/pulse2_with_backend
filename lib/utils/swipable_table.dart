import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/utils/note_viewer.dart';

class SwipableTable extends StatelessWidget {
  const SwipableTable({super.key});

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
            0: FixedColumnWidth(100), // Time column width
            1: FixedColumnWidth(60),
            2: FixedColumnWidth(60),
            3: FixedColumnWidth(60),
            4: FixedColumnWidth(60),
            5: FixedColumnWidth(80),
            6: FixedColumnWidth(100),
            7: FixedColumnWidth(60),
            8: FixedColumnWidth(120),
            9: FixedColumnWidth(60),
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
            ...List.generate(15, (index) {
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isOdd ? const Color(0xffF5F5F5) : Colors.white,
                ),
                children: [
                  _buildContainerCell('08:00', index),
                  _buildContainerCell('98', index),
                  _buildContainerCell('37.5', index),
                  _buildContainerCell('120', index),
                  _buildContainerCell('18', index),
                  _buildContainerCell('120/80', index),
                  _buildContainerCell('98%, 95', index),
                  _buildContainerCell('0.5L', index),
                  _buildContainerCell('3', index),
                  _buildContainerCell('14', index),
                  _buildButtonCell(index, context),
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
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
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
  Widget _buildButtonCell(int index, BuildContext context) {
    return Container(
      height: 35, // Reduced height for button cell
      alignment: Alignment.center,

      child: IconButton(
        icon: const Icon(
          FontAwesomeIcons.solidBookmark,
          color: Color(0xffFCAD00),
        ),
        onPressed: () {
          // print('Favorite button pressed for row $index');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const NoteViewer();
              });
        },
      ),
    );
  }
}
