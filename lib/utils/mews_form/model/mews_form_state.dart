import 'package:tuh_mews/models/patient_id_name.dart';

class MewsFormState {
  final PatientIdName? selectedPatient;

  const MewsFormState({this.selectedPatient});

  MewsFormState copyWith({PatientIdName? selectedPatient}) {
    return MewsFormState(selectedPatient: selectedPatient);
  }
}
