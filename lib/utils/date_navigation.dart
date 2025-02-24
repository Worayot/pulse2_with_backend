import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DateNavigation extends StatefulWidget {
  const DateNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DateNavigationState createState() => _DateNavigationState();
}

class _DateNavigationState extends State<DateNavigation> {
  DateTime selectedDate = DateTime.now();

  void _decreaseDate() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _increaseDate() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xff407bff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: _decreaseDate,
            child: const FaIcon(
              FontAwesomeIcons.caretLeft,
              size: 30,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration:
                    TextDecoration.underline, // Add underline decoration
                decorationColor: Colors.white,
              ),
            ),
          ),
          // Check if the selected date is today, if true, hide the increase button
          SizedBox(
            width: 15,
            child: Visibility(
              visible: selectedDate
                  .isBefore(DateTime.now().subtract(const Duration(days: 1))),
              child: InkWell(
                onTap: _increaseDate,
                child: const FaIcon(
                  FontAwesomeIcons.caretRight,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
