import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/mainpage/patient_related/patient_in_system_initilizer.dart';
import 'package:tuh_mews/mainpage/patient_related/export.dart';
import 'package:tuh_mews/mainpage/patient_related/monitored_patient.dart';
// import 'package:tuh_mews/mainpage/patient_data/monitored_patient_original.dart';
import 'package:tuh_mews/mainpage/settings/setting.dart';
import 'package:tuh_mews/utils/navbar.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // Single index to manage navigation
  int _selectedIndex = 0;

  // Different pages for each tab
  static final List<Widget> _pages = <Widget>[
    const NotificationPage(),
    const PatientPage(),
    const ExportPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        savePreference("male_toggle_state", false);
        savePreference("female_toggle_state", false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen size information
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Adjusting sizes based on screen width (responsive design)
    double iconSize =
        screenWidth * 0.045; // Relative icon size based on screen width
    double fontSize = screenWidth * 0.03;
    double bottomBarHeight =
        screenHeight * 0.95; // Responsive bottom bar height

    // double iconSize = 18;
    // double fontSize = 18;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomAnimatedBottomBar(
        selectedIndex: _selectedIndex, // Use the same selected index
        onItemSelected: _onItemTapped, // Handle item selection
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.house, size: iconSize),
            title: Text(
              "\t${'patientsInSystem'.tr()}",
              style: TextStyle(fontSize: fontSize), // Relative text size
            ),
            activeColor: const Color(0xffFEFEFE),
            inactiveColor: const Color(0xffC6D8FF),
            boxWidth: screenWidth * 0.4,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.users, size: iconSize),
            title: Text(
              "\t${'patientInMonitoring'.tr()}",
              style: TextStyle(fontSize: fontSize), // Relative text size
            ),
            activeColor: const Color(0xffFEFEFE),
            inactiveColor: const Color(0xffC6D8FF),
            boxWidth: screenWidth * 0.4,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.fileArrowDown, size: iconSize),
            title: Text(
              'data'.tr(),
              style: TextStyle(fontSize: fontSize), // Relative text size
            ),
            activeColor: const Color(0xffFEFEFE),
            inactiveColor: const Color(0xffC6D8FF),
            boxWidth: screenWidth * 0.3,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesomeIcons.gear, size: iconSize),
            title: Text(
              'settings'.tr(),
              style: TextStyle(fontSize: fontSize), // Relative text size
            ),
            activeColor: const Color(0xffFEFEFE),
            inactiveColor: const Color(0xffC6D8FF),
            boxWidth: screenWidth * 0.33,
          ),
        ],
        height: bottomBarHeight, // Adjusting bottom bar height responsively
      ),
    );
  }
}
