import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pulse/func/notification_scheduler.dart';

void showTimeManager(
  BuildContext context,
  double screenWidth,
  double screenHeight,
) {
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
                                          children: List<Widget>.generate(24, (
                                            index,
                                          ) {
                                            return Center(
                                              child: Text(
                                                index.toString().padLeft(
                                                  2,
                                                  '0',
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }),
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
                                          children: List<Widget>.generate(60, (
                                            index,
                                          ) {
                                            return Center(
                                              child: Text(
                                                index.toString().padLeft(
                                                  2,
                                                  '0',
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     print(
                        //         "Selected Time: $selectedHour:$selectedMinute");

                        //     Navigator.of(context).pop();
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(
                        //         vertical: 12,
                        //         horizontal: 20,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(15),
                        //       ),
                        //       backgroundColor: const Color(0xffC6D8FF)),
                        //   child: Text("setNotification".tr(),
                        //       style: const TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.black)),
                        // ),
                        ElevatedButton(
                          onPressed: () {
                            print(
                              "Selected Time: $selectedHour:$selectedMinute",
                            );

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

                            NotificationScheduler().scheduleNotificationAtTime(
                              notificationTime,
                              'Your notification message here', // Replace with your message
                            );

                            Navigator.of(context).pop();
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
}
