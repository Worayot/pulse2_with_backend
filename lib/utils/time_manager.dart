import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tuh_mews/func/notification_scheduler.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/func/string_transformer.dart';
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/services/mews_services.dart';
import 'package:timezone/data/latest.dart'
    as tzdata; // Import for initializeTimeZones
import 'package:timezone/timezone.dart'
    as tz; // Import for timezone functionality
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void showTimeManager({
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String auditorID,
  required String patientID,
  required VoidCallback onPop,
  required String patientName,
}) {
  // Initialize timezone database first
  _loadTimezone().then((_) {
    if (!context.mounted) return; // Ensure the widget is still available

    int selectedHour = 0;
    int selectedMinute = 0;

    FixedExtentScrollController hourController = FixedExtentScrollController(
      initialItem: selectedHour,
    );
    FixedExtentScrollController minuteController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: const EdgeInsets.only(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
            ),
            content: SizedBox(
              height: 400,
              child: Stack(
                children: [
                  Positioned(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "notifications".tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: -20,
                    child: Opacity(
                      opacity: 1,
                      child: Image.asset(
                        './assets/images/timeline.png',
                        width: 270,
                        height: 270,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        top: 38,
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: FractionallySizedBox(
                          alignment: Alignment.center,
                          widthFactor: 0.6,
                          heightFactor: 0.2,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: const Color(0xffC6D8FF),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: const Offset(0.5, 0.25),
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: Text(
                              "setTimer".tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SizedBox(
                              height: 130,
                              width: 160,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: ListWheelScrollView.useDelegate(
                                      controller: hourController,
                                      itemExtent: 50,
                                      perspective: 0.005,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        selectedHour = index;
                                      },
                                      childDelegate:
                                          ListWheelChildLoopingListDelegate(
                                            children: List<Widget>.generate(
                                              24,
                                              (index) {
                                                return Center(
                                                  child: Text(
                                                    index.toString().padLeft(
                                                      2,
                                                      '0',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    ),
                                  ),
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListWheelScrollView.useDelegate(
                                      controller: minuteController,
                                      itemExtent: 50,
                                      perspective: 0.005,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        selectedMinute = index;
                                      },
                                      childDelegate:
                                          ListWheelChildLoopingListDelegate(
                                            children: List<Widget>.generate(
                                              60,
                                              (index) {
                                                return Center(
                                                  child: Text(
                                                    index.toString().padLeft(
                                                      2,
                                                      '0',
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              DateTime now = DateTime.now();
                              DateTime notificationTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedHour,
                                selectedMinute,
                              );

                              if (notificationTime.isBefore(now)) {
                                notificationTime = notificationTime.add(
                                  Duration(days: 1),
                                );
                              }

                              // print('stringToHash');
                              // print(stringToHash);
                              InspectionNote newInspection = InspectionNote(
                                patientID: patientID,
                                auditorID: auditorID,
                                time: notificationTime,
                              );

                              try {
                                //! This does not verify that MEWsService() has successfully added new inspection note
                                await MEWsService().addNewInspection(
                                  inspectionNote: newInspection,
                                );
                                print('Inspection added to Firestore');

                                String stringToHash =
                                    patientID + notificationTime.toString();

                                int alarmId = StringTransformer().generateID(
                                  stringToHash,
                                );

                                print(stringToHash);

                                var alarmSettings = AlarmSettings(
                                  id: alarmId,
                                  // id: Uuid().v4().hashCode,
                                  dateTime: notificationTime,
                                  assetAudioPath: "assets/audio/alarm.mp3",
                                  loopAudio: false,
                                  vibrate: true,
                                  warningNotificationOnKill: true,
                                  androidFullScreenIntent: true,
                                  volumeSettings: VolumeSettings.fixed(
                                    volume: 0.8,
                                    volumeEnforced: true,
                                  ),
                                  notificationSettings: NotificationSettings(
                                    title: 'TUH MEWs',
                                    body:
                                        '${'remindAssess'.tr()} "$patientName"',
                                    stopButton: 'stop'.tr(),
                                    icon: 'notification_icon',
                                  ),
                                );

                                await AlarmService().setAlarm(alarmSettings);

                                // Set alarm 5 minutes before the initial alarm
                                if (notificationTime.difference(now).inMinutes >
                                    5) {
                                  print(
                                    "Scheduled Time before 5 minutes of the set time.",
                                  );

                                  if (notificationTime
                                          .difference(DateTime.now())
                                          .inMinutes >
                                      5) {
                                    String secondStringToHash =
                                        patientID +
                                        notificationTime
                                            .subtract(
                                              const Duration(minutes: 5),
                                            )
                                            .toString();

                                    int secondAlarmId = StringTransformer()
                                        .generateID(secondStringToHash);
                                    // print('secondStringToHash');
                                    // print(secondStringToHash);
                                    final alarmSettingsBefore = alarmSettings
                                        .copyWith(
                                          // id: Uuid().v4().hashCode,
                                          id: secondAlarmId,
                                          dateTime: notificationTime.subtract(
                                            const Duration(minutes: 5),
                                          ),
                                        );
                                    await AlarmService().setAlarm(
                                      alarmSettingsBefore,
                                    ); // Use the service
                                  }

                                  // print(
                                  //   'Scheduled Time: ${notificationTime.subtract(Duration(minutes: 5))}',
                                  // );
                                }
                              } catch (e) {
                                print(
                                  'Failed to add inspection to Firestore: $e',
                                );
                              }

                              if (!context.mounted) {
                                return; // Check before popping
                              }
                              Navigator.of(context).pop();
                              onPop();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: const Color(0xffC6D8FF),
                            ),
                            child: Text(
                              "setNotification".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  });
}

// Function to initialize the timezone database
Future<void> _loadTimezone() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Bangkok')); // Set local timezone
  print("Timezone initialized!");
}

// Save active alarm ID to SharedPreferences
Future<void> saveAlarmId(int alarmId) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> alarmIds = prefs.getStringList('activeAlarms') ?? [];
  alarmIds.add(alarmId.toString());
  await prefs.setStringList('activeAlarms', alarmIds);
}

// Stop an alarm manually
Future<void> stopAlarm(int alarmId) async {
  await Alarm.stop(alarmId);
  print('Alarm $alarmId stopped');

  // Remove the ID from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  List<String> alarmIds = prefs.getStringList('activeAlarms') ?? [];
  alarmIds.remove(alarmId.toString());
  await prefs.setStringList('activeAlarms', alarmIds);
}

// Stop all active alarms
// Future<void> stopAllAlarms() async {
//   final prefs = await SharedPreferences.getInstance();
//   List<String> alarmIds = prefs.getStringList('activeAlarms') ?? [];

//   for (String id in alarmIds) {
//     await Alarm.stop(int.parse(id));
//     print('Alarm $id stopped');
//   }

//   // Clear stored alarms
//   await prefs.remove('activeAlarms');
// }

//* Function that will be triggered when the alarm goes off
// void onAlarmTriggered(int alarmId) async {
//   // Delete the alarm from preferences when triggered
//   await deleteAlarmFromPrefs(alarmId);

//   // You can also perform other actions here, such as showing a dialog or notifying the user
//   print(
//     "Alarm with ID $alarmId has been triggered and deleted from preferences.",
//   );
// }

// Future<void> _deleteAlarm(int id) async {
//   await Alarm.stop(id);
//   final prefs = await SharedPreferences.getInstance();
//   List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];

//   savedAlarms.removeWhere((item) {
//     final data = jsonDecode(item);
//     return data['id'] == id;
//   });

//   await prefs.setStringList('scheduled_alarms', savedAlarms);
//   // _loadAlarms();
// }

// Future<void> _loadAlarms() async {
//   final prefs = await SharedPreferences.getInstance();
//   List<String> savedAlarms = prefs.getStringList('scheduled_alarms') ?? [];
//   setState(() {
//     _alarms =
//         savedAlarms.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
//   });
// }
