import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/note.dart';
import 'package:tuh_mews/models/parameters.dart';

class MEWsService {
  //* Used
  Future<Map<int, String>> addMEWs(String noteID, Parameters parameters) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    final noteRef = db.collection("inspection_notes").doc(noteID);

    try {
      final noteDoc = await noteRef.get();
      if (!noteDoc.exists) {
        return {404: "Inspection note not found"};
      }

      final noteData = noteDoc.data() as Map<String, dynamic>;
      final String? mewsId = noteData['mews_id'] as String?;

      final mewsMap = parameters.toJson();
      final utcTime = mewsMap['assessed_time'];
      final batch = db.batch();

      String resultantMewsId;

      if (mewsId != null && mewsId.isNotEmpty) {
        final mewRef = db.collection("mews").doc(mewsId);
        batch.update(mewRef, mewsMap);
        batch.update(noteRef, {"time": utcTime});
        resultantMewsId = mewsId;
      } else {
        final newMewRef = db.collection("mews").doc();
        batch.set(newMewRef, mewsMap);
        batch.update(noteRef, {"mews_id": newMewRef.id, "time": utcTime});
        resultantMewsId = newMewRef.id;
      }

      await batch.commit();

      return {200: resultantMewsId};
    } catch (e) {
      return {500: 'Failed to save MEWS data: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> addNote({required String noteID, required Note note}) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    final docRef = db.collection('inspection_notes').doc(noteID);

    try {
      final noteData = note.toJson();
      await docRef.update(noteData);

      return {
        200: jsonEncode({"message": "Note updated successfully", "note_id": noteID}),
      };
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return {404: "Inspection note document not found."};
      } else if (e.code == 'permission-denied') {
        return {403: "Permission denied."};
      } else {
        return {500: "Firebase error: ${e.message}"};
      }
    } catch (e) {
      return {500: "Error updating note: $e"};
    }
  }

  //* Used
  Future<Map<int, String>> addNewInspection({required InspectionNote inspectionNote}) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    try {
      final noteRef = db.collection("inspection_notes").doc();
      final mewRef = db.collection("mews").doc();

      final noteData = {...inspectionNote.toJson(), 'mews_id': mewRef.id, 'text': '-'};

      final mewData = {
        "blood_pressure": "-",
        "consciousness": "-",
        "cvp": "-",
        "heart_rate": "-",
        "mews": "-",
        "patient_id": inspectionNote.patientID,
        "respiratory_rate": "-",
        "spo2": "-",
        "temperature": "-",
        "urine": "-",
        "is_assessed": false,
      };

      final batch = db.batch();

      batch.set(noteRef, noteData);
      batch.set(mewRef, mewData);
      await batch.commit();

      return {
        200: jsonEncode({"message": "inspection_notes added successfully", "inspection_notes_id": noteRef.id}),
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return {403: "Permission denied."};
      } else {
        return {500: "Firebase error: ${e.message}"};
      }
    } catch (e) {
      return {500: "Error adding inspection: $e"};
    }
  }
}
