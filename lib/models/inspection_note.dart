class InspectionNote {
  final String patientID;
  final String auditorID;
  final DateTime time;

  InspectionNote({
    required this.patientID,
    required this.auditorID,
    required this.time,
  });

  factory InspectionNote.fromJson(Map<String, dynamic> json) {
    return InspectionNote(
      patientID: json['patient_id'],
      auditorID: json['audit_by'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'patient_id': patientID, 'audit_by': auditorID, 'time': time};
  }
}

// patient_id: str
// audit_by: str
// time: datetime
