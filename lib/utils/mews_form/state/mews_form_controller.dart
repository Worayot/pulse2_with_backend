import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/models/patient_id_name.dart';
import 'package:tuh_mews/utils/mews_form/model/mews_form_state.dart';

class MewsFormController extends AutoDisposeNotifier<MewsFormState> {
  @override
  MewsFormState build() {
    return const MewsFormState();
  }

  void setPatient(PatientIdName? selectedPatient) {
    state = state.copyWith(selectedPatient: selectedPatient);
  }
}
