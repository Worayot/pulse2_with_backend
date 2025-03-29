import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DateNavigation extends StatefulWidget {
  final Function(DateTime) onDateChanged; // Callback function

  const DateNavigation({super.key, required this.onDateChanged});

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
    widget.onDateChanged(selectedDate); // Notify parent widget with new date
  }

  void _increaseDate() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
    widget.onDateChanged(selectedDate); // Notify parent widget with new date
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
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 15,
            child: Visibility(
              visible: selectedDate.isBefore(DateTime.now()),
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
