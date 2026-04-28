import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/utils/mews_form/mews_forms_instant.dart';

class GlobalMewsFAB extends StatelessWidget {
  final String userId;

  const GlobalMewsFAB({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xff3362CC),
      elevation: 2,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return InstantMEWsForm(auditorID: userId, onPop: () {}, showPatientSelector: true);
          },
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Icon(FontAwesomeIcons.calculator, color: Colors.white, size: 28),
    );
  }
}
