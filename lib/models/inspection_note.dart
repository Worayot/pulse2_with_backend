import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class InspectionNote {
  final String patientID;
  final String auditorID;
  final DateTime time;

  InspectionNote({required this.patientID, required this.auditorID, required this.time});

  // Convert JSON to InspectionNote (No change needed)
  factory InspectionNote.fromJson(Map<String, dynamic> json) {
    return InspectionNote(patientID: json['patient_id'], auditorID: json['audit_by'], time: _convertToLocalTimezone(json['time']));
  }

  // Convert InspectionNote to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientID,
      'audit_by': auditorID,
      'time': time, // <-- Save the DateTime object directly
    };
  }

  // No change needed
  static DateTime _convertToLocalTimezone(Timestamp timestamp) {
    DateTime utcDateTime = timestamp.toDate();
    final bangkokTimezone = tz.getLocation('Asia/Bangkok');
    final localDateTime = tz.TZDateTime.from(utcDateTime, bangkokTimezone);
    return localDateTime;
  }

  @override
  String toString() {
    // No change needed, but saving 'time' directly is better
    return "time: $time";
  }
}
