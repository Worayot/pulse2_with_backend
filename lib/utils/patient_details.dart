import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tuh_mews/mainpage/patient_related/patient_in_system.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/utils/report_widget.dart';

void showPatientDetails(BuildContext context, var patient) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  String fullname = patient["fullname"];
  List nameParts = fullname.split(' ');
  String name = nameParts[0];
  String surname = nameParts[1];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 0,
                  child: Text(
                    'report'.tr(),
                    style: TextStyle(
                      // fontSize: screenWidth * 0.05,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black,
                      // size: screenWidth * 0.06,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        "assets/images/therapy.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          displayData(
                            context,
                            "name-surname".tr(),
                            "$name $surname",
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .start, // Aligns children to the start
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Ensures vertical alignment is centered
                            children: [
                              Expanded(
                                child: displayData(
                                  context,
                                  "age".tr(),
                                  "${patient["age"]}",
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ), // Adds space between the two displayData widgets
                              Expanded(
                                child: displayData(
                                  context,
                                  "gender".tr(),
                                  '${patient["gender"]}'.tr(),
                                ),
                              ),
                            ],
                          ),
                          displayData(
                            context,
                            "bedNumber".tr(),
                            patient["bed_number"],
                          ),
                          displayData(
                            context,
                            "hn".tr(),
                            patient["hospital_number"],
                          ),
                          displayData(context, "ward".tr(), patient["ward"]),
                          SizedBox(
                            height: screenHeight * 0.6,
                            child: ReportWidget(
                              tableHeight: screenHeight * 0.5,
                              patientID: patient['patient_id'],
                            ),
                          ),
                        ],
                      ),
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

Widget displayData(BuildContext context, String title, String content) {
  return SizedBox(
    width: double.infinity,
    child: Row(
      children: [
        Text(title),
        const SizedBox(
          width: 8,
        ), // Optional: adds space between title and text field
        Expanded(
          // This ensures TextField takes up the remaining space
          child: TextField(
            readOnly: true, // Makes the text field non-editable
            controller: TextEditingController(text: content),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );
}
