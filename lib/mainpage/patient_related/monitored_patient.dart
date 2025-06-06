// ignore_for_file: library_private_types_in_public_api
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';
import 'package:tuh_mews/mainpage/patient_related/no_patient_screen.dart';
import 'package:tuh_mews/utils/action_button.dart';
import 'package:tuh_mews/utils/mews_forms_general.dart';
import 'package:tuh_mews/utils/notification_list_page.dart';
import 'package:tuh_mews/utils/patient_card_monitored.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  String myUserId = '';

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myUserId = prefs.getString('nurseID') ?? "N/A";
    });
  }

  Future<void> refreshData() async {
    // Perform any asynchronous work here
    await Future.delayed(Duration(seconds: 1)); // Example of async work
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double paddingSize = size.width * 0.04; // Responsive padding

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: paddingSize),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "patientInMonitoring".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getPageTitleSize(context),
                  ),
                ),
                //* TUH MEWS 2.0
                // Row(
                //   children: [
                //     buildActionButton(
                //       FontAwesomeIcons.solidBell,
                //       () {
                //         showDialog(
                //           context: context,
                //           builder: (context) {
                //             return Dialog(
                //               backgroundColor: Color(0xffE0EAFF),
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(16),
                //               ),
                //               child: Padding(
                //                 padding: const EdgeInsets.all(16.0),
                //                 child: NotificationsDialogContent(),
                //               ),
                //             );
                //           },
                //         );
                //       },
                //       const Color(0xff3362CC),
                //       Colors.white,
                //     ),
                //     SizedBox(width: 8),
                //     buildActionButton(
                //       FontAwesomeIcons.calculator,
                //       () {
                //         showDialog(
                //           context: context,
                //           builder: (BuildContext context) {
                //             return MEWsFormsGeneral();
                //           },
                //         );
                //       },
                //       const Color(0xff3362CC),
                //       Colors.white,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebasePatientService().fetchMonitoredPatients(myUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                children: [
                  SizedBox(height: size.height * 0.15),
                  const NoPatientWidget(),
                ],
              );
            } else {
              List<Map<String, dynamic>> patients = snapshot.data!;

              // Sort patients by name
              patients.sort(
                (a, b) => a['patient_details']['fullname'].compareTo(
                  b['patient_details']['fullname'],
                ),
              );

              return ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> patientData = patients[index];
                  return MonitoredPatientCard(
                    patientData: patientData,
                    onPop: refreshData,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
