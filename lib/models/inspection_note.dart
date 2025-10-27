import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
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

Future<void> _loadTimezone() async {
  // Initialize timezone package
  tzdata.initializeTimeZones();
  print("Timezone initialized!");
}

// void main() async {
//   await _loadTimezone(); // Call this before using the timezone functionality

//   // Example usage of InspectionNote
//   final exampleTimestamp = Timestamp.fromDate(DateTime.utc(2023, 10, 15, 10, 0)); // Example UTC timestamp
//   final inspectionNote = InspectionNote.fromJson({
//     'patient_id': '12345',
//     'audit_by': 'auditor_1',
//     'time': exampleTimestamp,
//   });

//   print('Patient ID: ${inspectionNote.patientID}');
//   print('Auditor ID: ${inspectionNote.auditorID}');
//   print('Time (local): ${inspectionNote.time}');

//   // Convert InspectionNote back to JSON
//   final json = inspectionNote.toJson();
//   print('JSON: $json');
// }
