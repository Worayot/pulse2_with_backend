import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuh_mews/func/string_transformer.dart';
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/services/mews_services.dart';
import 'package:timezone/data/latest.dart' as tzdata; // Import for initializeTimeZones
import 'package:timezone/timezone.dart' as tz; // Import for timezone functionality
import 'package:tuh_mews/utils/flushbar.dart';

void showTimeManager({
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String auditorID,
  required String patientID,
  required VoidCallback onPop,
  required String patientName,
  String? previousMews,
}) {
  _loadTimezone().then((_) {
    if (!context.mounted) return;

    int selectedHour = 0;
    int selectedMinute = 0;

    FixedExtentScrollController hourController = FixedExtentScrollController(initialItem: selectedHour);
    FixedExtentScrollController minuteController = FixedExtentScrollController(initialItem: selectedMinute);

    bool enableButton = true;
    int highMewsThreshold = 3;

    final previousScore = int.tryParse(previousMews ?? '') ?? 0;

    final sound = previousScore >= highMewsThreshold ? 'alarm2' : 'alarm';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                content: SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text("notifications".tr(), textScaler: const TextScaler.linear(1.0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.black, size: 30),
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
                        child: Opacity(opacity: 1, child: Image.asset('./assets/images/timeline.png', width: 270, height: 270, fit: BoxFit.contain)),
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
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), offset: const Offset(0.5, 0.25), blurRadius: 1, spreadRadius: 1)],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 60.0),
                                child: Text("setTimer".tr(), textScaler: const TextScaler.linear(1.0), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                                          childDelegate: ListWheelChildLoopingListDelegate(
                                            children: List<Widget>.generate(24, (index) {
                                              return Center(
                                                child: Text(
                                                  index.toString().padLeft(2, '0'),
                                                  textScaler: const TextScaler.linear(1.0),
                                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      const Text(":", textScaler: TextScaler.linear(1.0), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: ListWheelScrollView.useDelegate(
                                          controller: minuteController,
                                          itemExtent: 50,
                                          perspective: 0.005,
                                          physics: const FixedExtentScrollPhysics(),
                                          onSelectedItemChanged: (index) {
                                            selectedMinute = index;
                                          },
                                          childDelegate: ListWheelChildLoopingListDelegate(
                                            children: List<Widget>.generate(60, (index) {
                                              return Center(
                                                child: Text(
                                                  index.toString().padLeft(2, '0'),
                                                  textScaler: const TextScaler.linear(1.0),
                                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      const Gap(30),
                                    ],
                                  ),
                                ),
                              ),
                              Gap(30),
                              ElevatedButton(
                                onPressed:
                                    enableButton
                                        ? () async {
                                          setState(() {
                                            enableButton = false;
                                          });

                                          final now = DateTime.now();

                                          DateTime rawTime = DateTime(now.year, now.month, now.day, selectedHour, selectedMinute, now.second);

                                          if (rawTime.isBefore(now)) {
                                            rawTime = rawTime.add(const Duration(days: 1));
                                          }

                                          final tz.TZDateTime notificationTime = tz.TZDateTime.local(
                                            rawTime.year,
                                            rawTime.month,
                                            rawTime.day,
                                            rawTime.hour,
                                            rawTime.minute,
                                            rawTime.second,
                                          );

                                          final tz.TZDateTime recordTime = notificationTime;

                                          InspectionNote newInspection = InspectionNote(patientID: patientID, auditorID: auditorID, time: recordTime);

                                          try {
                                            Map<int, String> status = await MEWsService().addNewInspection(inspectionNote: newInspection);

                                            if (status.containsKey(200)) {
                                              String stringToHash = patientID + recordTime.toString();

                                              int alarmId = StringTransformer().generateID(stringToHash);

                                              await AlarmService().setAlarm(
                                                id: alarmId,
                                                dateTime: notificationTime,
                                                title: 'TUH MEWs',
                                                body: '${'remindAssess'.tr()} "$patientName"',
                                                patientID: patientID,
                                                sound: sound,
                                              );

                                              final diff = notificationTime.difference(tz.TZDateTime.now(tz.local));

                                              if (diff.inMinutes > 5) {
                                                final secondNotificationTime = notificationTime.subtract(const Duration(minutes: 5));

                                                String secondStringToHash = patientID + secondNotificationTime.toString();

                                                int secondAlarmId = StringTransformer().generateID(secondStringToHash);

                                                await AlarmService().setAlarm(
                                                  id: secondAlarmId,
                                                  dateTime: secondNotificationTime,
                                                  title: 'TUH MEWs',
                                                  body: '${'remindAssess'.tr()} "$patientName"',
                                                  patientID: patientID,
                                                  sound: sound,
                                                );
                                              }

                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }

                                              onPop();
                                            } else {
                                              setState(() {
                                                enableButton = true;
                                              });
                                              throw "Failed to add note";
                                            }
                                          } catch (e) {
                                            setState(() {
                                              enableButton = true;
                                            });

                                            debugPrint('Error: $e');

                                            if (context.mounted) {
                                              FlushbarService.showErrorMessage(context: context, message: 'failedToSetNotification'.tr());
                                            }
                                          }
                                        }
                                        : () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  backgroundColor: const Color(0xffC6D8FF),
                                ),
                                child:
                                    enableButton
                                        ? Text(
                                          "setNotification".tr(),
                                          textScaler: const TextScaler.linear(1.0),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        )
                                        : CircularProgressIndicator(color: Colors.white),
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
      },
    );
  });
}

Future<void> _loadTimezone() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

  var status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }
}
