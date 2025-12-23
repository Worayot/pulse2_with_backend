import 'package:cloud_firestore/cloud_firestore.dart';

class InspectionNoteModel {
  final DateTime time;
  final dynamic mewsScore;
  final bool isAssessed;
  final String mewsId;
  final String noteId;
  final String noteText;
  final String auditor;

  InspectionNoteModel({
    required this.time,
    required this.mewsScore,
    required this.isAssessed,
    required this.mewsId,
    required this.noteId,
    required this.noteText,
    required this.auditor,
  });

  factory InspectionNoteModel.fromMap(Map<String, dynamic> map) {
    // Handle Firestore Timestamp conversion
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return DateTime.now(); // Fallback
    }

    return InspectionNoteModel(
      time: parseTime(map['time']),
      mewsScore: map['mews']?['mews'] ?? '-',
      isAssessed: map['mews']?['is_assessed'] ?? false,
      mewsId: map['mews_id'] ?? '',
      noteId: map['note_id'] ?? '',
      noteText: map['text'] ?? '',
      auditor: map['audit_by'] ?? '',
    );
  }
}

class PatientModel {
  final String patientId;
  final String userId;
  final String fullname;
  final List<InspectionNoteModel> inspectionNotes;

  PatientModel({required this.patientId, required this.userId, required this.fullname, required this.inspectionNotes});

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    var notesList = map['inspection_notes'] as List<dynamic>? ?? [];
    List<InspectionNoteModel> parsedNotes = notesList.map((note) => InspectionNoteModel.fromMap(note as Map<String, dynamic>)).toList();

    return PatientModel(patientId: map['patient_id'] ?? '', userId: map['user_id'] ?? '', fullname: map['patient_details']?['fullname'] ?? 'Unknown', inspectionNotes: parsedNotes);
  }
}
