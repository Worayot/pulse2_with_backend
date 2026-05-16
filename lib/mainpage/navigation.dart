import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/mainpage/patient_related/patient_in_system.dart';
import 'package:tuh_mews/mainpage/patient_related/export.dart';
import 'package:tuh_mews/mainpage/patient_related/monitored_patient.dart';
import 'package:tuh_mews/mainpage/settings/setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/state/authentication_state/authentication_state.dart';
import 'package:tuh_mews/utils/global_mews_fab.dart';
import 'package:tuh_mews/utils/navbar.dart';

class NavigationPage extends ConsumerStatefulWidget {
  final bool isFreshLogin;
  final String? sessionCookie;
  const NavigationPage({super.key, this.isFreshLogin = false, this.sessionCookie});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  // Single index to manage navigation
  int _selectedIndex = 0;
  String userId = '';

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
    final isAuthenticated = await ref.read(authenticationProvider).isAuthenticated();
    if (!isAuthenticated && widget.sessionCookie == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isFreshLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuthentication();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 24;
    double fontSize = 20;

    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          DraggableFloatWidget(
            config: DraggableFloatWidgetBaseConfig(
              isFullScreen: false,
              appBarHeight: kToolbarHeight,

              // Initial Position (Bottom-Right)
              initPositionXInLeft: false, // false = Start on the right
              initPositionYInTop: false, // false = Start at the bottom
              // Distance from the bottom edge
              initPositionYMarginBorder: 0,

              // Boundaries from screen edges
              borderRight: 8,
              borderBottom: 8,
              borderTop: 8,
              borderLeft: 8,
              // Visuals
              animDuration: const Duration(milliseconds: 100),
              debug: false,
            ),
            child: GlobalMewsFAB(userId: userId),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xff3362CC),
        child: SafeArea(
          top: false,
          child: Material(
            child: CustomAnimatedBottomBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.hospitalUser, size: iconSize),
                  title: FittedBox(fit: BoxFit.scaleDown, child: Text("\t${'patientsInSystem'.tr()}", style: TextStyle(fontSize: fontSize))),
                  activeColor: const Color(0xffFEFEFE),
                  inactiveColor: const Color(0xffC6D8FF),
                ),
                BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.clipboardUser, size: iconSize),
                  title: FittedBox(fit: BoxFit.scaleDown, child: Text("\t${'patientInMonitoring'.tr()}", style: TextStyle(fontSize: fontSize))),
                  activeColor: const Color(0xffFEFEFE),
                  inactiveColor: const Color(0xffC6D8FF),
                ),
                BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.fileArrowDown, size: iconSize),
                  title: FittedBox(fit: BoxFit.scaleDown, child: Text('data'.tr(), style: TextStyle(fontSize: fontSize))),
                  activeColor: const Color(0xffFEFEFE),
                  inactiveColor: const Color(0xffC6D8FF),
                ),
                BottomNavyBarItem(
                  icon: Icon(FontAwesomeIcons.gear, size: iconSize),
                  title: FittedBox(fit: BoxFit.scaleDown, child: Text('settings'.tr(), style: TextStyle(fontSize: fontSize))),
                  activeColor: const Color(0xffFEFEFE),
                  inactiveColor: const Color(0xffC6D8FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
