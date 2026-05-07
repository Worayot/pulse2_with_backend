// ignore_for_file: library_private_types_in_public_api
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/models/monitored_patient/card_model.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/mainpage/patient_related/no_patient_screen.dart';
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(28),
              FittedBox(fit: BoxFit.scaleDown, child: Text("patientInMonitoring".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.left)),
              const Gap(8),
              Expanded(
                // Update Type: Now listens for List<PatientModel>
                child: StreamBuilder<List<PatientModel>>(
                  stream: FirebasePatientService().fetchMonitoredPatients(myUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(children: [SizedBox(height: size.height * 0.15), const NoPatientWidget()]);
                    } else {
                      List<PatientModel> patients = snapshot.data!;

                      patients.sort((a, b) => a.fullname.compareTo(b.fullname));

                      // debugPrint(patients.toString());

                      return ListView.builder(
                        itemCount: patients.length,
                        // Add cacheExtent to improve scroll smoothness
                        cacheExtent: 1000,
                        itemBuilder: (context, index) {
                          return MonitoredPatientCard(patient: patients[index], onPop: refreshData);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
