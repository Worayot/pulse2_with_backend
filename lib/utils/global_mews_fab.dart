import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/utils/mews_form/mews_forms_instant.dart';

class GlobalMewsFAB extends StatelessWidget {
  final String userId;

  const GlobalMewsFAB({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xff3362CC),
      elevation: 2,
      shape: const CircleBorder(),

      onPressed: () async {
        showDialog(
          context: context,
          builder: (_) {
            return InstantMEWsForm(auditorID: userId, onPop: () {}, showPatientSelector: true);
          },
        );
      },
      child: const Icon(FontAwesomeIcons.calculator, color: Colors.white, size: 28),
    );
  }
}
