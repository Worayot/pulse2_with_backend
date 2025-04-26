import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/utils/custom_header.dart';
import 'package:async/async.dart';
import 'package:fl_chart/fl_chart.dart';

class AboutAppPageTwo extends StatelessWidget {
  const AboutAppPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();
    final patientsStream =
        FirebaseFirestore.instance.collection('patients').snapshots();

    final combinedStream = StreamZip([usersStream, patientsStream]);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the default back button
        title: const Header(),
        toolbarHeight: size.height * 0.13,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB2C2E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Image.asset(
                              "assets/images/doctor.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.backward,
                                      color: Colors.black,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'back'.tr(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'aboutSoftware'.tr(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // White container
                              Container(
                                padding: const EdgeInsets.all(30.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(
                                        0,
                                        3,
                                      ), // Position of the shadow
                                    ),
                                  ],
                                ),
                                child: StreamBuilder<List<QuerySnapshot>>(
                                  stream: combinedStream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return CircularProgressIndicator();
                                    }

                                    final usersDocs = snapshot.data![0].docs;
                                    final patientsDocs = snapshot.data![1].docs;

                                    int userCount = usersDocs.length;
                                    int patientCount = patientsDocs.length;

                                    Map<String, int> genderCounts = {};

                                    for (var doc in patientsDocs) {
                                      // Safely access the data and the 'gender' field
                                      var data =
                                          doc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >?; // Cast to Map<String, dynamic>?
                                      if (data != null) {
                                        var gender =
                                            data['gender']
                                                as String?; // Safely access 'gender' as String?
                                        if (gender != null &&
                                            gender.isNotEmpty) {
                                          // Increment the count for this gender
                                          genderCounts[gender] =
                                              (genderCounts[gender] ?? 0) + 1;
                                        }
                                      }
                                    }

                                    Map<String, int> userTypeCounts = {};

                                    for (var doc in usersDocs) {
                                      // Safely access the data and the 'gender' field
                                      var data =
                                          doc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >?; // Cast to Map<String, dynamic>?
                                      if (data != null) {
                                        var role =
                                            data['role']
                                                as String?; // Safely access 'role' as String?
                                        if (role != null && role.isNotEmpty) {
                                          // Increment the count for this role
                                          userTypeCounts[role] =
                                              (userTypeCounts[role] ?? 0) + 1;
                                        }
                                      }
                                    }
                                    print(userTypeCounts);

                                    int femalePatientCount =
                                        genderCounts['Female'] ?? 0;
                                    int malePatientCount =
                                        genderCounts['Male'] ?? 0;

                                    int nurseCount =
                                        userTypeCounts['nurse'] ?? 0;
                                    int adminCount =
                                        userTypeCounts['admin'] ?? 0;

                                    // print(patientsDocs[0].data());

                                    return SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // ...usersDocs.map((doc) {
                                          //   final data =
                                          //       doc.data()
                                          //           as Map<String, dynamic>;
                                          //   return Text(data.toString());
                                          // }),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              infoBox(
                                                title: "Total Users",
                                                disc: userCount.toString(),
                                                cardColor: Color(0xff407BFF),
                                                textColor: Colors.white,
                                              ),
                                              infoBox(
                                                title: "Total Patients",
                                                disc: patientCount.toString(),
                                                cardColor: Color(0xff407BFF),
                                                textColor: Colors.white,
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // Text('Patients:'),
                                          // ...patientsDocs.map((doc) {
                                          //   final data =
                                          //       doc.data()
                                          //           as Map<String, dynamic>;

                                          //   return Text(
                                          //     '• ${data['fullname'].toString()}',
                                          //   );
                                          // }),
                                          // const SizedBox(height: 16),
                                          // Text('Patients:'),
                                          // ...patientsDocs.map((doc) {
                                          //   final data =
                                          //       doc.data()
                                          //           as Map<String, dynamic>;
                                          //   return Text('• ${data.toString()}');
                                          // }),
                                          // const SizedBox(height: 16),
                                          Text(
                                            'User Type Distribution:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                200, // Adjust height as needed
                                            width:
                                                200, // Adjust width as needed
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                UserPieChart(
                                                  nurseCount: nurseCount,
                                                  adminCount: adminCount,
                                                ),
                                                Text(
                                                  'Total\nUsers',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildLegend(
                                                color: Colors.orangeAccent,
                                                text: 'User',
                                              ),
                                              SizedBox(width: 10),
                                              _buildLegend(
                                                color: Colors.yellowAccent,
                                                text: 'Admin',
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),
                                          Text(
                                            'Patient Gender Distribution:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(
                                            height:
                                                200, // Adjust height as needed
                                            width:
                                                200, // Adjust width as needed
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                GenderPieChart(
                                                  femalePatientCount:
                                                      femalePatientCount,
                                                  malePatientCount:
                                                      malePatientCount,
                                                ),
                                                Text(
                                                  'Total\nPatients',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildLegend(
                                                color: Colors.pinkAccent,
                                                text: 'Female patient',
                                              ),
                                              SizedBox(width: 10),
                                              _buildLegend(
                                                color: Colors.blueAccent,
                                                text: 'Male patient',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
            ],
          ),
        ),
      ),
    );
  }
}

Widget infoBox({
  required String title,
  required String disc,
  required Color textColor,
  required Color cardColor,
}) {
  return Card(
    elevation: 1,
    color: cardColor,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            disc,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}

class GenderPieChart extends StatelessWidget {
  final int femalePatientCount;
  final int malePatientCount;

  const GenderPieChart({
    super.key,
    required this.femalePatientCount,
    required this.malePatientCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalPatients = femalePatientCount + malePatientCount;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: femalePatientCount.toDouble(),
        title:
            '${(femalePatientCount / totalPatients * 100).toStringAsFixed(1)}%',
        color: Colors.pinkAccent,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: malePatientCount.toDouble(),
        title:
            '${(malePatientCount / totalPatients * 100).toStringAsFixed(1)}%',
        color: Colors.blueAccent,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 40,
        sectionsSpace: 0,
      ),
    );
  }
}

class UserPieChart extends StatelessWidget {
  final int nurseCount;
  final int adminCount;

  const UserPieChart({
    super.key,
    required this.nurseCount,
    required this.adminCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalUsers = nurseCount + adminCount;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: nurseCount.toDouble(),
        title: '${(nurseCount / totalUsers * 100).toStringAsFixed(1)}%',
        color: Colors.yellowAccent,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        value: adminCount.toDouble(),
        title: '${(adminCount / totalUsers * 100).toStringAsFixed(1)}%',
        color: Colors.orangeAccent,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 40,
        sectionsSpace: 0,
      ),
    );
  }
}

Widget _buildLegend({required Color color, required String text}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(text),
    ],
  );
}
