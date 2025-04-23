import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsDialogContent extends StatefulWidget {
  @override
  _NotificationsDialogContentState createState() =>
      _NotificationsDialogContentState();
}

class _NotificationsDialogContentState
    extends State<NotificationsDialogContent> {
  List<Map<String, dynamic>> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];
    setState(() {
      _alarms =
          savedAlarms
              .map((e) => jsonDecode(e) as Map<String, dynamic>)
              .toList();
    });
  }

  Future<void> _deleteAlarm(int id) async {
    await Alarm.stop(id);
    final prefs = await SharedPreferences.getInstance();
    List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

    savedAlarms.removeWhere((item) {
      final data = jsonDecode(item);
      return data['id'] == id;
    });

    await prefs.setStringList('scheduled_alarms', savedAlarms);
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Scheduled Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          _alarms.isEmpty
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No scheduled notifications'),
              )
              : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return Card(
                      color: Color(0xffF5F5F5),
                      child: ListTile(
                        title: Text(alarm['title']),
                        subtitle: Text(
                          '${alarm['body']}\n${alarm['dateTime']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAlarm(alarm['id']),
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
