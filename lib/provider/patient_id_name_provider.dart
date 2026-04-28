import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/models/patient_id_name.dart';
import 'package:tuh_mews/services/patient_services.dart';

final patientListProvider = StreamProvider<List<PatientIdName>>((ref) {
  return FirebasePatientService().streamPatientIdNames();
});
