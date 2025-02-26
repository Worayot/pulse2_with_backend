// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pulse/models/patient.dart';
import 'package:pulse/services/patient_services.dart';
import 'package:pulse/universal_setting/sizes.dart';
import 'package:pulse/func/get_color.dart';
import 'package:pulse/mainpage/patient_data/no_patient_screen.dart';
import 'package:pulse/utils/action_button.dart';
import 'package:pulse/utils/circle_with_num.dart';
import 'package:pulse/utils/table_row.dart';
import 'package:pulse/utils/time_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final patientServices = PatientService();
  List<Patient> _patients = [];
  String myUserId = '';
  Map<String, dynamic>? monitoredPatientData = {};

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      myUserId = prefs.getString('nurseID') ?? "N/A";
    });
  }

  Future<void> fetchMonitoredPatient() async {
    monitoredPatientData = await patientServices.getMonitoredPatient(myUserId);

    if (monitoredPatientData != null) {
      print("Successfully retrieved Monitored Patient Data.");
    } else {
      print("No monitored patient data available or error occurred.");
    }
  }

  Future<List<DocumentSnapshot>> fetchPatientsFromMonitoredData(
    Map<String, dynamic> monitoredPatientData,
  ) async {
    List<DocumentSnapshot> patientDocs = [];

    if (monitoredPatientData['message'] == 'Links retrieved successfully' &&
        monitoredPatientData['data'] is List) {
      List<String> patientIds =
          (monitoredPatientData['data'] as List)
              .map((item) => item['data']['patient_id'].toString())
              .toList();

      try {
        if (patientIds.isNotEmpty) {
          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance
                  .collection('patients')
                  .where(FieldPath.documentId, whereIn: patientIds)
                  .get();

          patientDocs = querySnapshot.docs;
        } else {
          print('No patient IDs to fetch.');
        }
      } catch (e) {
        print('Error fetching patients: $e');
      }
    } else {
      print('Invalid Monitored Patient Data format.');
    }

    return patientDocs;
  }

  Future<void> _initializeData() async {
    await _loadProfileData();
    await fetchMonitoredPatient();
    List<DocumentSnapshot> data = await fetchPatientsFromMonitoredData(
      monitoredPatientData!,
    );
    List<Patient> patients = [];
    Patient patient;
    for (DocumentSnapshot doc in data) {
      // Extract data from Firestore document
      var patientData = doc.data() as Map<String, dynamic>;

      // Extract values from the data
      String? gender = patientData['gender'];
      String? bedNumber = patientData['bed_number'];
      String? ward = patientData['ward'];
      String? age = patientData['age'];
      String? hospitalNumber = patientData['hospital_number'];
      String? fullname = patientData['fullname'];
      Timestamp createdAt = patientData['created_at'];

      // Create a Patient instance using the extracted values
      patient = Patient(
        age: age ?? '', // Handle null or empty data
        bedNumber: bedNumber ?? '',
        fullname: fullname ?? '',
        gender: gender ?? '',
        ward: ward ?? '',
        hospitalNumber: hospitalNumber ?? '',
        createdAt:
            createdAt.toDate().toString(), // Assuming createdAt is a Timestamp
      );

      patients.add(patient);
    }
    patients.sort((a, b) => a.fullname.compareTo(b.fullname));
    setState(() {
      _patients = patients;
    });
  }

  List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      setState(() {
        _expandedStates = List<bool>.filled(
          _patients.length,
          false,
        ); // Dynamically update expanded states
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    double paddingSize = screenWidth * 0.04; // Responsive padding

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: paddingSize),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "patientInMonitoring".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: getPageTitleSize(context),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_patients.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    Patient patient = _patients[index];

                    DateTime monitorTime =
                        // patient.nextMonitoring ??
                        DateTime.now();
                    String formattedDatetime = DateFormat(
                      'HH.mm',
                    ).format(monitorTime);
                    Duration timeDifference = monitorTime.difference(
                      DateTime.now(),
                    );

                    int hours = timeDifference.inHours;
                    int minutes = timeDifference.inMinutes % 60;

                    String formattedTime = '';
                    if (hours > 0 || minutes > 0) {
                      formattedTime += '(';
                    }
                    if (hours > 0) {
                      formattedTime += '$hours ${"hour".tr()} ';
                    }
                    if (minutes > 0) {
                      formattedTime += '$minutes ${"minute".tr()})';
                    }
                    if (formattedTime.isEmpty) {
                      formattedTime = '';
                    }

                    bool isExpanded = _expandedStates[index];
                    List<Map<String, dynamic>> data =
                        // patient.previousData ??
                        [];
                    int data_length = data.length;
                    List<String> times = [];
                    List<String> previous_MEWs = [];

                    for (var map in data) {
                      for (var entry in map.entries) {
                        times.add(entry.key);
                        previous_MEWs.add(entry.value);
                      }
                    }

                    String latest_MEWs = "";
                    if (previous_MEWs.isEmpty) {
                      latest_MEWs = "-";
                    } else if (previous_MEWs.length == 1) {
                      latest_MEWs = previous_MEWs[0];
                    } else if (previous_MEWs.length > 1 &&
                        previous_MEWs.last == "-") {
                      latest_MEWs = previous_MEWs[previous_MEWs.length - 2];
                    } else {
                      latest_MEWs = previous_MEWs.last;
                    }

                    bool hasData = data.isEmpty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Stack(
                        children: [
                          // Expanded Content
                          Positioned(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Match the container's radius
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedStates[index] =
                                          !_expandedStates[index]; // Toggle state
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.only(top: 16),
                                    height:
                                        _expandedStates[index]
                                            ? (screenHeight * 0.033 + 8) *
                                                    data_length +
                                                96
                                            : 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff98B1E8),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min, // Adjust height dynamically
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 70,
                                          ), // Static height for header
                                          if (isExpanded) ...[
                                            Column(
                                              children: List.generate(
                                                data_length,
                                                (i) {
                                                  return TableRowWidget(
                                                    MEWs: previous_MEWs[i],
                                                    time: times[i],
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Collapsed Header
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xffE0EAFF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedStates[index] =
                                          !_expandedStates[index]; // Toggle state
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4.0,
                                          right: 12,
                                        ),
                                        child: CircleWithNumber(
                                          number: latest_MEWs,
                                          color: getColor(latest_MEWs),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              // "${patient.name} ${patient.surname}",
                                              patient.fullname,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.04,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    offset: const Offset(
                                                      0.4,
                                                      0.4,
                                                    ),
                                                    blurRadius: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "nextInspectionTime".tr(),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "$formattedDatetime${"n".tr()} $formattedTime",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      buildActionButton(
                                        FontAwesomeIcons.solidClock,
                                        () {
                                          showTimeManager(
                                            context,
                                            screenWidth,
                                            screenHeight,
                                          );
                                        },
                                        Colors.white,
                                        const Color(0xff3362CC),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Assess Text and Icon
                          if (!hasData)
                            Positioned(
                              top: 75, // Adjust the position to fit your layout
                              left: screenWidth / 2.5,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _expandedStates[index] =
                                            !_expandedStates[index];
                                      });
                                    },
                                    child: Text(
                                      "assess".tr(),
                                    ), // This stays in place
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_patients.isEmpty)
              Column(
                children: [
                  SizedBox(height: size.height * 0.15),
                  const NoPatientWidget(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
