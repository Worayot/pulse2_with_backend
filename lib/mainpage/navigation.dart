import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/mainpage/patient_related/patient_in_system.dart';
import 'package:tuh_mews/mainpage/patient_related/export.dart';
import 'package:tuh_mews/mainpage/patient_related/monitored_patient.dart';
// import 'package:tuh_mews/mainpage/patient_data/monitored_patient_original.dart';
import 'package:tuh_mews/mainpage/settings/setting.dart';
import 'package:tuh_mews/state/authentication_state/authentication_state.dart';
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
  static final List<Widget> _pages = <Widget>[const PatientInSystem(), const PatientPage(), const ExportPage(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        savePreference("male_toggle_state", false);
        savePreference("female_toggle_state", false);
      }
    });
  }

  Future<void> _checkAuthentication() async {
    final isAuthenticated = await AuthenticationState().isAuthenticated();
    if (!isAuthenticated) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  void initState() {
    _checkAuthentication();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.045;
    double fontSize = 14;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CustomAnimatedBottomBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              icon: Icon(FontAwesomeIcons.userGroup, size: iconSize),
              title: FittedBox(fit: BoxFit.scaleDown, child: Text("\t${'patientsInSystem'.tr()}", style: TextStyle(fontSize: fontSize))),
              activeColor: const Color(0xffFEFEFE),
              inactiveColor: const Color(0xffC6D8FF),
              boxWidth: screenWidth * 0.4,
            ),
            BottomNavyBarItem(
              icon: Icon(FontAwesomeIcons.userNurse, size: iconSize),
              title: FittedBox(fit: BoxFit.scaleDown, child: Text("\t${'patientInMonitoring'.tr()}", style: TextStyle(fontSize: fontSize))),
              activeColor: const Color(0xffFEFEFE),
              inactiveColor: const Color(0xffC6D8FF),
              boxWidth: screenWidth * 0.4,
            ),
            BottomNavyBarItem(
              icon: Icon(FontAwesomeIcons.fileArrowDown, size: iconSize),
              title: FittedBox(fit: BoxFit.scaleDown, child: Text('data'.tr(), style: TextStyle(fontSize: fontSize))),
              activeColor: const Color(0xffFEFEFE),
              inactiveColor: const Color(0xffC6D8FF),
              boxWidth: screenWidth * 0.3,
            ),
            BottomNavyBarItem(
              icon: Icon(FontAwesomeIcons.gear, size: iconSize),
              title: FittedBox(fit: BoxFit.scaleDown, child: Text('settings'.tr(), style: TextStyle(fontSize: fontSize))),
              activeColor: const Color(0xffFEFEFE),
              inactiveColor: const Color(0xffC6D8FF),
              boxWidth: screenWidth * 0.33,
            ),
          ],
        ),
      ),
    );
  }
}
