import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/services/export_services.dart';
import 'package:tuh_mews/services/validate_service.dart';
import 'package:tuh_mews/utils/action_button.dart';

class PatientCardExport extends StatefulWidget {
  final Patient patient;

  const PatientCardExport({super.key, required this.patient});

  @override
  _PatientCardExportState createState() => _PatientCardExportState();
}

class _PatientCardExportState extends State<PatientCardExport> {
  bool enableButton = true;

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
                              widget.patient.fullname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 2),
                            if (widget.patient.gender == "Male")
                              const Icon(
                                Icons.male, // For male
                                color: Colors.blue,
                                size: 26.0,
                              ),
                            if (widget.patient.gender == "Female")
                              const Icon(
                                Icons.female, // For female
                                color: Colors.pink,
                                size: 26.0,
                              ),
                            const SizedBox(width: 3),
                            Text(
                              "(${widget.patient.age} ${"yrs".tr()})",
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
                              widget.patient.ward,
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
                              widget.patient.bedNumber,
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
                              widget.patient.hospitalNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                overflow: TextOverflow.clip,
                              ),
                              maxLines: 1,
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
              icon: enableButton ? FontAwesomeIcons.fileExport : null,
              onPressed:
                  enableButton
                      ? () async {
                        setState(() {
                          enableButton = false;
                        });

                        final exportService = ExportServices();
                        Map<int, String> status = await exportService.export([
                          widget.patient.patientId ?? '',
                        ]);
                        ValidateService(
                          status: status,
                          navigator: Navigator.of(context),
                        ).validate();

                        setState(() {
                          enableButton = true;
                        });
                      }
                      : () {},
              bgColor: Colors.white,
              iconColor: const Color(0xff4B74D1),
            ),
          ),
        ],
      ),
    );
  }
}
