// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/universal_setting/sizes.dart';
import 'package:pulse/utils/symbols_dialog/home_symbols.dart';
import 'package:pulse/utils/symbols_dialog/info_dialog.dart';
import 'package:pulse/mainpage/patient_related/patient_in_system.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen size information
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Adjusting text size based on screen width
    double iconSize =
        screenWidth * 0.08; // Scaling icon size based on screen width
    double paddingSize =
        screenWidth * 0.04; // Scaling padding based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: paddingSize),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "patientsInSystem".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: getPageTitleSize(context), // Responsive text size
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: paddingSize),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.circleInfo,
                size: iconSize, // Responsive icon size
                color: const Color(0xff3362CC),
              ),
              onPressed: () {
                showInfoDialog(context, homeSymbols());
              },
            ),
          ),
        ],
      ),
      body: const PatientInSystem(),
    );
  }
}
