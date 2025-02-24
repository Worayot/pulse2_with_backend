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
    if (selectedDate.isBefore(DateTime.now())) {
      setState(() {
        selectedDate = selectedDate.add(const Duration(days: 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xff407bff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.caretLeft,
              size: 20,
              color: Colors.white,
            ),
            onPressed: _decreaseDate,
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(selectedDate),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.caretRight,
              size: 20,
              color: Colors.white,
            ),
            onPressed:
                selectedDate.isBefore(DateTime.now()) ? _increaseDate : null,
          ),
        ],
      ),
    );
  }
}
