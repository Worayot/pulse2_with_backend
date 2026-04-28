import 'package:flutter/material.dart';

class PatientFilterState {
  final String name;
  final String surname;
  final String ward;
  final String hn;
  final String bedNumber;
  final bool male;
  final bool female;
  final RangeValues ageRange;

  PatientFilterState({
    this.name = '',
    this.surname = '',
    this.ward = '',
    this.hn = '',
    this.bedNumber = '',
    this.male = false,
    this.female = false,
    this.ageRange = const RangeValues(0, 120),
  });

  PatientFilterState copyWith({String? name, String? surname, String? ward, String? hn, String? bedNumber, bool? male, bool? female, RangeValues? ageRange}) {
    return PatientFilterState(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      ward: ward ?? this.ward,
      hn: hn ?? this.hn,
      bedNumber: bedNumber ?? this.bedNumber,
      male: male ?? this.male,
      female: female ?? this.female,
      ageRange: ageRange ?? this.ageRange,
    );
  }
}
