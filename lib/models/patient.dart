class Patient {
  final String? createdAt;
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

  // Factory constructor to create a Patient instance from JSON data
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      createdAt: json['created_at'],
      age: json['age'],
      bedNumber: json['bed_number'],
      fullname: json['fullname'],
      gender: json['gender'],
      ward: json['ward'],
      hospitalNumber: json['hospital_number'],
      patientId: json['patient_id'],
    );
  }

  // Convert a Patient instance to JSON (for sending to the server)
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'age': age,
      'bed_number': bedNumber,
      'fullname': fullname,
      'gender': gender,
      'ward': ward,
      'hospital_number': hospitalNumber,
      'patient_id': patientId,
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
