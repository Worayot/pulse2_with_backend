import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientReportDateSwitcher extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final DateTime? selectedDay;

  const PatientReportDateSwitcher({super.key, required this.onDateChanged, this.selectedDay});

  @override
  // ignore: library_private_types_in_public_api
  _PatientReportDateSwitcherState createState() => _PatientReportDateSwitcherState();
}

class _PatientReportDateSwitcherState extends State<PatientReportDateSwitcher> {
  DateTime selectedDate = DateTime.now();

  Future<void> showCalendarDialog(BuildContext context) async {
    DateTime selectedDay = widget.selectedDay ?? DateTime.now();

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
                    Text("selectDate".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Gap(10),

                    TableCalendar(
                      locale: Localizations.localeOf(context).toString(),
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: false,
                        selectedDecoration: BoxDecoration(color: Color(0xffC6D8FF), shape: BoxShape.circle),
                        selectedTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),

                      focusedDay: selectedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay, day);
                      },
                      onDaySelected: (newSelectedDay, newFocusedDay) {
                        setState(() {
                          selectedDay = newSelectedDay;
                        });

                        widget.onDateChanged(newSelectedDay);
                      },
                    ),

                    const Gap(10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xff407BFF)),
                          onPressed: () {
                            Navigator.pop(context, selectedDay);
                          },
                          child: Text("ok".tr(), style: TextStyle(color: Colors.white)),
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
          SizedBox(width: 15, child: InkWell(onTap: _increaseDate, child: const FaIcon(FontAwesomeIcons.caretRight, size: 30, color: Colors.white))),
        ],
      ),
    );
  }
}
