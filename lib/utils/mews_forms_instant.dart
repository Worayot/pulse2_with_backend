import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/func/calculateMEWs.dart';
import 'package:tuh_mews/func/notification_scheduler.dart';
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/parameters.dart';
import 'package:tuh_mews/results/result_screens.dart';
import 'package:tuh_mews/services/mews_services.dart';

class InstantMEWsForm extends StatefulWidget {
  final String patientID;
  final String auditorID;
  // final String noteID;
  final VoidCallback onPop;

  const InstantMEWsForm({
    super.key,
    required this.patientID,
    required this.auditorID,
    // required this.noteID,
    required this.onPop,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InstantMEWsFormState createState() => _InstantMEWsFormState();
}

class _InstantMEWsFormState extends State<InstantMEWsForm> {
  // Declare TextEditingController for each input field
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController sysBloodPressureController =
      TextEditingController();
  final TextEditingController diaBloodPressureController =
      TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController respiratoryRateController =
      TextEditingController();
  final TextEditingController urineController = TextEditingController();
  final TextEditingController cvpController = TextEditingController();
  final FocusNode sysBpFocusNode = FocusNode();
  final FocusNode diasBpFocusNode = FocusNode();
  String consciousnessValue = "-";

  @override
  void dispose() {
    heartRateController.dispose();
    temperatureController.dispose();
    sysBloodPressureController.dispose();
    diaBloodPressureController.dispose();
    spo2Controller.dispose();
    respiratoryRateController.dispose();
    urineController.dispose();
    super.dispose();
    sysBpFocusNode.dispose();
    diasBpFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showMEWsForms(context);
  }

  Widget _showMEWsForms(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Adjust radius here
          ),
          color: const Color(0xFFD7E0F5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "calculateMEWs".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "consciousness".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: DropdownButtonFormField<String>(
                      value: consciousnessValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          consciousnessValue = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: "-",
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text("-"),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Conscious",
                          child: Text("conscious".tr()),
                        ),
                        DropdownMenuItem(
                          value: "Alert",
                          child: Text("alert".tr()),
                        ),
                        DropdownMenuItem(
                          value: "verbalStimuli",
                          child: Text("verbalStimuli".tr()),
                        ),
                        DropdownMenuItem(
                          value: "Pain",
                          child: Text("pain".tr()),
                        ),
                        DropdownMenuItem(
                          value: "Unresponsive",
                          child: Text("unresponsive".tr()),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "temperature".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "(°C)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40, // Adjust height here
                    child: TextField(
                      controller: temperatureController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ), // Allows only numbers and one decimal point
                      ],
                      decoration: InputDecoration(
                        hintText: '-',
                        suffix: const Text(
                          '°C',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ), // Adjusts height/padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide:
                              BorderSide.none, // Removes visible border line
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      children: [
                        Text(
                          "heartRate".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Text(
                          "(bpm)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40, // Adjust height here
                    child: TextField(
                      controller: heartRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "-",
                        suffix: const Text(
                          "bpm",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16, // Adjusts height/padding
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "respiratoryRate".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "(bpm)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: respiratoryRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        suffix: const Text(
                          "bpm",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        hintText: '-',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ), // Adjusts height/padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide:
                              BorderSide.none, // Removes visible border line
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "bloodPressure".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "(mmHg)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Systolic",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                focusNode: sysBpFocusNode,
                                onChanged: (value) {
                                  if (value.length == 3) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(diasBpFocusNode);
                                  }
                                },
                                controller: sysBloodPressureController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '-',
                                  suffix: const Text(
                                    "mmHg",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "Diastolic",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                focusNode: diasBpFocusNode,
                                controller: diaBloodPressureController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '-',
                                  suffix: const Text(
                                    "mmHg",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "spO2 (${"whileGivingOxygen".tr()})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "(%)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: spo2Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '-',
                        suffix: const Text(
                          "%",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ), // Adjusts height/padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide:
                              BorderSide.none, // Removes visible border line
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "urine".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "(mL/hr)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40, // Adjust height here
                    child: TextField(
                      controller: urineController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '-',
                        suffix: const Text(
                          "mL/hr",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ), // Adjusts height/padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide:
                              BorderSide.none, // Removes visible border line
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          "CVP",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40, // Adjust height here
                    child: TextField(
                      controller: cvpController,
                      // keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '-',

                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ), // Adjusts height/padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded corners
                          borderSide:
                              BorderSide.none, // Removes visible border line
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                // Use a separate variable
                                return AlertDialog(
                                  title: Text("confirmAction".tr()),
                                  content: Text("proceed?".tr()),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          dialogContext,
                                        ).pop(false); // User pressed cancel
                                      },
                                      child: Text("cancel".tr()),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          dialogContext,
                                        ).pop(true); // User confirmed
                                      },
                                      child: Text("confirm".tr()),
                                    ),
                                  ],
                                );
                              },
                            ).then((confirmed) {
                              if (mounted && confirmed == true) {
                                setState(() {
                                  // Ensure UI updates properly
                                  heartRateController.text = "";
                                  temperatureController.text = "";
                                  sysBloodPressureController.text = "";
                                  diaBloodPressureController.text = "";
                                  spo2Controller.text = "";
                                  respiratoryRateController.text = "";
                                  urineController.text = "";
                                  cvpController.text = "";
                                  consciousnessValue =
                                      "-"; // Reset dropdown safely
                                });
                              }
                            });
                          },
                          child: Text(
                            'reset'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red, // Text color
                              decoration:
                                  TextDecoration
                                      .underline, // Underline to indicate it's clickable
                              decorationColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF3362CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                15,
                              ), // Set border radius here
                            ),
                          ),
                          onPressed: () async {
                            DateTime now = DateTime.now();

                            // Add new Note in Database collection
                            InspectionNote newInspection = InspectionNote(
                              patientID: widget.patientID,
                              auditorID: widget.auditorID,
                              time: now,
                            );

                            String inspectionNotesID = '';

                            try {
                              // Get NoteID from response
                              String response = await MEWsService()
                                  .addNewInspection(
                                    inspectionNote: newInspection,
                                  );
                              print('Inspection added to Firestore');
                              Map<String, dynamic> decoded = jsonDecode(
                                response,
                              );
                              inspectionNotesID =
                                  decoded['inspection_notes_id'];
                              // print(inspectionNotesId);
                            } catch (e) {
                              print('Failed: $e');
                            }

                            String hr = heartRateController.text.trim();
                            String temp = temperatureController.text.trim();
                            String sBp = sysBloodPressureController.text.trim();
                            String dBp = diaBloodPressureController.text.trim();
                            String spO2 = spo2Controller.text.trim();
                            String rr = respiratoryRateController.text.trim();
                            String urine = urineController.text.trim();
                            String conscious = consciousnessValue;
                            String cvp = cvpController.text.trim();

                            hr = (hr == ' ') ? '-' : hr;
                            temp = (temp == ' ') ? '-' : temp;
                            sBp = (sBp == ' ') ? '-' : sBp;
                            dBp = (dBp == ' ') ? '-' : dBp;
                            spO2 = (spO2 == ' ') ? '-' : spO2;
                            rr = (rr == ' ') ? '-' : rr;
                            urine = (urine == ' ') ? '-' : urine;
                            cvp = (cvp == ' ') ? '-' : cvp;

                            int MEWs = calculateMEWs(
                              consciousness: conscious,
                              heartRate: (hr != '-') ? int.tryParse(hr) : null,
                              temperature:
                                  (temp != '-') ? double.tryParse(temp) : null,
                              respiratoryRate:
                                  (rr != '-') ? int.tryParse(rr) : null,
                              systolicBp:
                                  (sBp != '-') ? int.tryParse(sBp) : null,
                              spo2: (spO2 != '-') ? int.tryParse(spO2) : null,
                              urine:
                                  (urine != '-') ? int.tryParse(urine) : null,
                            );

                            Navigator.pop(context);

                            Parameters parameters = Parameters(
                              patientId: widget.patientID,
                              consciousness: conscious,
                              heartRate: hr,
                              urine: urine,
                              spo2: spO2,
                              temperature: temp,
                              respiratoryRate: rr,
                              bloodPressure: '$sBp/$dBp',
                              mews: MEWs.toString(),
                              cvp: cvp,
                              isAssessed: true,
                            );
                            showResultDialog(
                              context: context,
                              MEWs: MEWs,
                              noteID: inspectionNotesID,
                              onPop: widget.onPop,
                            );
                            MEWsService().addMEWs(
                              inspectionNotesID,
                              parameters,
                            );
                            widget.onPop();
                          },
                          child: Text(
                            'calculate'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          right: 15,
          child: IconButton(
            icon: const Icon(
              Icons.close, // Close icon
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
