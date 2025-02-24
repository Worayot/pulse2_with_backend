import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/utils/info_box.dart';
import 'package:pulse/utils/report_widget.dart';

class PatientIndData extends StatefulWidget {
  final String age;
  final String gender;
  final String hn;
  final String bedNum;
  final String ward;
  final String MEWs;
  final String time;

  const PatientIndData(
      {super.key,
      required this.age,
      required this.gender,
      required this.hn,
      required this.bedNum,
      required this.ward,
      required this.time,
      required this.MEWs});

  @override
  // ignore: library_private_types_in_public_api
  _PatientIndDataState createState() => _PatientIndDataState();
}

class _PatientIndDataState extends State<PatientIndData> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16.0, top: 60),
      child: SingleChildScrollView(
        // Wrapping with SingleChildScrollView to handle overflow
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: infoBox(
                          title: "age".tr(),
                          content: widget.age,
                          boxColor: Colors.white,
                          context: context),
                    ),
                    Expanded(
                      child: infoBox(
                          title: "gender".tr(),
                          content: widget.gender,
                          boxColor: Colors.white,
                          context: context),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: infoBox(
                        title: "hn".tr(),
                        content: widget.hn,
                        boxColor: Colors.white,
                        context: context,
                      ),
                    ),
                    Expanded(
                      child: infoBox(
                        title: "bedNumber".tr(),
                        content: widget.bedNum,
                        boxColor: Colors.white,
                        context: context,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "ward".tr(),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            widget.ward,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    description(widget.time, widget.MEWs),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget description(String time, String MEWs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${"latestInspection".tr()} ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$time${"n".tr()}"),
              ],
            ),
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("${"latestMEWsScore".tr()} ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Text(MEWs,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
