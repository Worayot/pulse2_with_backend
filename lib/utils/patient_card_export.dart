import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/models/patient.dart';
import 'package:pulse/services/export_services.dart';
import 'package:pulse/utils/action_button.dart';

class PatientCardExport extends StatelessWidget {
  final Patient patient;

  const PatientCardExport({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // Space between card and screen
      child: Stack(
        children: [
          Card(
            elevation: 0,
            color: const Color(0xffE0EAFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patient.fullname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 2),
                            if (patient.gender == "Male")
                              const Icon(
                                Icons.male, // For male
                                color: Colors.blue,
                                size: 26.0,
                              ),
                            if (patient.gender == "Female")
                              const Icon(
                                Icons.female, // For female
                                color: Colors.pink,
                                size: 26.0,
                              ),
                            const SizedBox(width: 3),
                            Text(
                              "(${patient.age} ${"yrs".tr()})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${"ward".tr()} ',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              patient.ward,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              ' ${"bedNo".tr()} ',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              patient.bedNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${"hnNo".tr()} ',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              patient.hospitalNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 10,
            bottom: 0,
            child: ClipRect(
              child: SizedBox(
                height: 50,
                width: 150,
                child: Opacity(
                  opacity: 1, // Set the opacity to 50%
                  child: Image.asset(
                    'assets/images/therapy4.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 10,
            child: buildExportButton(
              FontAwesomeIcons.fileExport,
              () {
                print('Exporting: ${patient.fullname} ${patient.patientId}');
                final exportService = ExportServices();
                exportService.export([patient.patientId ?? '']);
              },
              Colors.white,
              const Color(0xff4B74D1),
            ),
          ),
        ],
      ),
    );
  }
}
