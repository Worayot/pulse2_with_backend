import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/mainpage/patient_related/patient_ind_data.dart';
import 'package:tuh_mews/models/patient_user_link.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/utils/action_button.dart';
import 'package:tuh_mews/utils/edit_patient_form.dart';
import 'package:tuh_mews/utils/patient_details.dart';
import 'package:tuh_mews/utils/toggle_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeExpandableCards extends StatefulWidget {
  final List filteredPatients;
  final BuildContext context;
  final List isExpanded;

  const HomeExpandableCards({
    super.key,
    required this.filteredPatients,
    required this.context,
    required this.isExpanded,
  });

  @override
  _HomeExpandableCardsState createState() => _HomeExpandableCardsState();
}

class _HomeExpandableCardsState extends State<HomeExpandableCards> {
  late StreamSubscription<List<String>>
  _streamSubscription; // Updated type to match the data (List<String>)
  late List<String> _linkedPatient; // Initialize it with an empty list
  String userID = '';

  Future<void> loadUID() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        userID = prefs.getString('nurseID') ?? "N/A";
      });
    }
  }

  void _startListeningToStream() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference patientsCollection = firestore.collection(
      'patient_user_links',
    );

    // Subscribe to the Firestore stream
    _streamSubscription = patientsCollection
        .snapshots()
        .map((querySnapshot) {
          List<String> patientIds = []; // List to store only patient_ids
          for (var document in querySnapshot.docs) {
            // Safely cast the document data to a Map<String, dynamic> and check for 'patient_id'
            var data = document.data() as Map<String, dynamic>?;
            if (data != null) {
              var patientId = data['patient_id'];
              if (patientId != null) {
                patientIds.add(
                  patientId as String,
                ); // Add patient_id to the list
              }
            }
          }
          return patientIds; // Return a list of patient_ids
        })
        .listen((linkedPatients) {
          // Update the list with new patient_ids
          if (mounted) {
            setState(() {
              _linkedPatient = linkedPatients;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    loadUID();
    _linkedPatient =
        []; // Initialize _linkedPatient to avoid LateInitializationError
    _startListeningToStream();
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    List isExpanded = widget.isExpanded;
    List filteredPatients = widget.filteredPatients;
    return ListView.builder(
      itemCount: filteredPatients.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> patient = filteredPatients[index];
        List<String> nameParts = patient["fullname"].split(' ');
        String name = nameParts[0];
        String surname = nameParts[1];
        String age = patient["age"].toString();
        String gender = patient["gender"];
        String hn = patient["hospital_number"];
        String bedNum = patient["bed_number"];
        String ward = patient["ward"];
        String MEWs = patient["MEWs"] ?? '-';
        String patientID = patient['patient_id'];
        String time = patient['inspectionTime'];

        String nextTimeText =
            time == '-'
                ? "${"latestInspection".tr()} -"
                : "${"latestInspection".tr()} $time${"n".tr()}";

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
          child: Stack(
            children: [
              // Expanded Content
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded[index] = !isExpanded[index];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.only(top: 16),
                        height: isExpanded[index] ? 380 : 82,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff98B1E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            isExpanded[index]
                                ? PatientIndData(
                                  age: age,
                                  gender: gender.tr(),
                                  hn: hn,
                                  bedNum: bedNum,
                                  ward: ward,
                                  MEWs: MEWs,
                                  time: time,
                                )
                                : const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),

              // Collapsed Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffE0EAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0, // Adjust the vertical position
                      right: 0, // Adjust the horizontal position
                      child: IgnorePointer(
                        child: Image.asset(
                          "assets/images/therapy3.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isExpanded[index] = !isExpanded[index];
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$name $surname",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              offset: const Offset(0.8, 0.8),
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${"bedNumber".tr()} ",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: bedNum,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        nextTimeText,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                                ToggleIconButton(
                                  addPatientFunc: () async {
                                    PatientUserLink link = PatientUserLink(
                                      patientID: patientID,
                                      userID: userID,
                                    );
                                    await PatientService().takeIn(link: link);
                                  },
                                  removePatientFunc: () async {
                                    await PatientService().takeOut(
                                      userId: userID,
                                      patientId: patientID,
                                    );
                                  },
                                  buttonState:
                                      !_linkedPatient.contains(patientID),
                                ),
                                const SizedBox(width: 8),
                                buildActionButton(
                                  FontAwesomeIcons.clipboardList,
                                  () {
                                    showPatientDetails(context, patient);
                                  },
                                  Colors.white,
                                  const Color(0xff3362CC),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return EditPatientForm(
                                            patientId: patientID,
                                            name: name,
                                            surname: surname,
                                            age: age,
                                            gender: gender,
                                            hn: hn,
                                            bedNum: bedNum,
                                            ward: ward,
                                          );
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 4,
                                      ),
                                    ),
                                    child: Text(
                                      "edit".tr(),
                                      style: const TextStyle(
                                        color: Color(0xff3362CC),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 69, // Adjust the position to fit your layout
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Text("details".tr()),
                      onTap: () {
                        setState(() {
                          isExpanded[index] = !isExpanded[index];
                        });
                      },
                    ),
                    Icon(
                      isExpanded[index] ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
