import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DateNavigation extends StatefulWidget {
  final Function(DateTime) onDateChanged; // Callback function

  const DateNavigation({super.key, required this.onDateChanged});

  @override
  // ignore: library_private_types_in_public_api
  _DateNavigationState createState() => _DateNavigationState();
}

class _DateNavigationState extends State<DateNavigation> {
  DateTime selectedDate = DateTime.now();

  Future<void> showCalendarDialog(BuildContext context) async {
    DateTime focusedDay = DateTime.now();
    DateTime? selectedDay;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selectedDay = selectedDay;
                          focusedDay = focusedDay;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, selectedDay);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        debugPrint("Selected date: $selectedDate");
        _setDate(selectedDate);
      }
    });
  }

  void _decreaseDate() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
    widget.onDateChanged(selectedDate);
  }

  void _increaseDate() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
    widget.onDateChanged(selectedDate);
  }

  void _setDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 150,
      decoration: BoxDecoration(color: const Color(0xff407bff), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(onTap: _decreaseDate, child: const FaIcon(FontAwesomeIcons.caretLeft, size: 30, color: Colors.white)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () => showCalendarDialog(context),
              child: Text(
                DateFormat('dd/MM/yyyy').format(selectedDate),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white),
              ),
            ),
          ),
          SizedBox(
            width: 15,
            child: Visibility(
              visible: selectedDate.isBefore(DateTime.now()),
              child: InkWell(onTap: _increaseDate, child: const FaIcon(FontAwesomeIcons.caretRight, size: 30, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
