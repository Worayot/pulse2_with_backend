import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final DateTime? createdAt;
  final String age;
  final String bedNumber;
  final String fullname;
  final String gender;
  final String ward;
  final String hospitalNumber;
  final String? patientId;

  Patient({
    this.createdAt,
    required this.age,
    required this.bedNumber,
    required this.fullname,
    required this.gender,
    required this.ward,
    required this.hospitalNumber,
    this.patientId,
  });

  factory Patient.fromJson(Map<String, dynamic> json, [String? documentId]) {
    return Patient(
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      age: json['age'],
      bedNumber: json['bed_number'],
      fullname: json['fullname'],
      gender: json['gender'],
      ward: json['ward'],
      hospitalNumber: json['hospital_number'],
      patientId: documentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'bed_number': bedNumber,
      'fullname': fullname,
      'gender': gender,
      'ward': ward,
      'hospital_number': hospitalNumber,
    };
  }

  @override
  String toString() {
    return 'Patient { '
        'fullname: $fullname, '
        'age: $age, '
        'bedNumber: $bedNumber, '
        'gender: $gender, '
        'ward: $ward, '
        'hospitalNumber: $hospitalNumber, '
        'patientId: $patientId, '
        'createdAt: $createdAt '
        '}';
  }
}
