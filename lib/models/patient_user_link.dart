class PatientUserLink {
  final String patientID;
  final String userID;

  PatientUserLink({required this.patientID, required this.userID});

  factory PatientUserLink.fromJson(Map<String, dynamic> json) {
    return PatientUserLink(
      patientID: json['patient_id'],
      userID: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'patient_id': patientID, 'user_id': userID};
  }
}
