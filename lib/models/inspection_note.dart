import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart'
    as tzdata; // Import for initializeTimeZones
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class InspectionNote {
  final String patientID;
  final String auditorID;
  final DateTime time;

  InspectionNote({
    required this.patientID,
    required this.auditorID,
    required this.time,
  });

  // Convert JSON to InspectionNote
  factory InspectionNote.fromJson(Map<String, dynamic> json) {
    return InspectionNote(
      patientID: json['patient_id'],
      auditorID: json['audit_by'],
      time: _convertToLocalTimezone(json['time']), // Convert to local timezone
    );
  }

  // Convert InspectionNote to JSON
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientID,
      'audit_by': auditorID,
      'time': DateFormat("yyyy-MM-ddTHH:mm:ss").format(time),
    };
  }

  // Function to convert UTC time to local time (Asia/Bangkok)
  static DateTime _convertToLocalTimezone(Timestamp timestamp) {
    DateTime utcDateTime =
        timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    final bangkokTimezone = tz.getLocation(
      'Asia/Bangkok',
    ); // Get the Bangkok timezone
    final localDateTime = tz.TZDateTime.from(
      utcDateTime,
      bangkokTimezone,
    ); // Convert to local time
    return localDateTime;
  }

  @override
  String toString() {
    return "time: $time\nformatted_time: ${DateFormat("yyyy-MM-ddTHH:mm:ss").format(time)}";
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
