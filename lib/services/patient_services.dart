import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/patient_user_link.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import '../models/patient.dart';

class FirebasePatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream monitored patients linked to the given user ID
  Stream<List<Map<String, dynamic>>> fetchMonitoredPatients(String userId) {
    return _firestore.collection('patient_user_links').where('user_id', isEqualTo: userId).snapshots().asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> monitoredPatients = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> patientData = doc.data();
          String patientId = patientData['patient_id'];

          // Fetch patient details from the 'patients' collection
          Map<String, dynamic>? patientDetails = await fetchPatientData(patientId);

          // Fetch inspection notes for this patient
          List<Map<String, dynamic>> inspectionNotes = await fetchInspectionNotes(patientId);

          // Add patient details and inspection notes to the monitored patient data
          if (patientDetails != null) {
            patientData['patient_details'] = patientDetails;
          }
          patientData['inspection_notes'] = inspectionNotes;
          monitoredPatients.add(patientData);
        }
      } else {
        // print("No monitored patient data found.");
      }

      return monitoredPatients;
    });
  }

  /// Fetch patient data from the 'patients' collection
  Future<Map<String, dynamic>?> fetchPatientData(String patientId) async {
    try {
      final DocumentSnapshot docSnapshot = await _firestore.collection('patients').doc(patientId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        // print("No patient data found for patientId $patientId");
        return null; // No patient data found
      }
    } catch (e) {
      // print("Error fetching patient data for patientId $patientId: $e");
      return null; // Error fetching patient data
    }
  }

  /// Fetch inspection notes for a specific patient
  Future<List<Map<String, dynamic>>> fetchInspectionNotes(String patientId) async {
    List<Map<String, dynamic>> inspectionNotes = [];

    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('inspection_notes').where('patient_id', isEqualTo: patientId).get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> noteData = doc.data() as Map<String, dynamic>;
        noteData['note_id'] = doc.id; // Add document ID (doc name)

        String? mewsId = noteData['mews_id'];

        if (mewsId != null && mewsId.isNotEmpty) {
          // Fetch MEWS data
          Map<String, dynamic>? mewsData = await fetchMewsData(mewsId);
          noteData['mews'] = mewsData; // Attach MEWS data to the note
        } else {
          noteData['mews'] = null; // No MEWS data available
        }

        inspectionNotes.add(noteData);
      }
    } catch (e) {
      // print("Error fetching inspection notes for patient $patientId: $e");
    }

    return inspectionNotes;
  }

  /// Fetch MEWS data using mews_id
  Future<Map<String, dynamic>?> fetchMewsData(String mewsId) async {
    try {
      final DocumentSnapshot docSnapshot = await _firestore.collection('mews').doc(mewsId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        return null; // No MEWS data found
      }
    } catch (e) {
      // print("Error fetching MEWS data for mews_id $mewsId: $e");
      return null;
    }
  }
}

class PatientService {
  //* Tested
  Future<Map<int, String>> addPatient(Patient patientData) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // 1. Check for authenticated user (replaces token check)
    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    try {
      Map<String, dynamic> patientMap = patientData.toJson();
      patientMap['created_at'] = FieldValue.serverTimestamp();

      final docRef = await db.collection("patients").add(patientMap);

      return {
        200: jsonEncode({"message": "Patient added successfully", "patient_id": docRef.id}),
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return {403: "Permission denied."};
      } else {
        return {500: "Firebase error: ${e.message}"};
      }
    } catch (e) {
      return {500: "Error adding patient: $e"};
    }
  }

  //* Tested
  Future<Map<int, String>> deletePatient(String patientId) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // 1. Check for authenticated user (replaces token check)
    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    try {
      final batch = db.batch();

      final patientRef = db.collection("patients").doc(patientId);
      final patientDoc = await patientRef.get();

      if (!patientDoc.exists) {
        return {404: "Patient not found"};
      }

      final inspectionNotesQuery = db.collection("inspection_notes").where("patient_id", isEqualTo: patientId);
      final inspectionNotesSnapshot = await inspectionNotesQuery.get();

      final List<String> mewsIdsToDelete = [];

      for (final noteDoc in inspectionNotesSnapshot.docs) {
        batch.delete(noteDoc.reference);

        final noteData = noteDoc.data();
        final String? mewsId = noteData["mews_id"] as String?;
        if (mewsId != null && mewsId.isNotEmpty) {
          mewsIdsToDelete.add(mewsId);
        }
      }

      for (final mewsId in mewsIdsToDelete.toSet()) {
        final mewRef = db.collection("mews").doc(mewsId);
        batch.delete(mewRef);
      }

      final linksQuery = db.collection("patient_user_links").where("patient_id", isEqualTo: patientId);
      final linksSnapshot = await linksQuery.get();

      for (final linkDoc in linksSnapshot.docs) {
        batch.delete(linkDoc.reference);
      }

      batch.delete(patientRef);
      await batch.commit();

      return {
        200: jsonEncode({"message": "Patient and all related records deleted successfully"}),
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return {403: "Permission denied."};
      } else {
        return {500: "Firebase error: ${e.message}"};
      }
    } catch (e) {
      return {500: "Error deleting patient: $e"};
    }
  }

  //* Used
  Future<Map<int, String>> updatePatient(String patientId, Patient patientData) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return {401: 'User is not authenticated.'};
    }

    final patientRef = db.collection("patients").doc(patientId);

    try {
      final patientMap = patientData.toJson();
      await patientRef.update(patientMap);

      return {
        200: jsonEncode({"message": "Patient updated successfully", "patient_id": patientId}),
      };
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return {404: "Patient not found"};
      } else if (e.code == 'permission-denied') {
        return {403: "Permission denied."};
      } else {
        return {500: "Firebase error: ${e.message}"};
      }
    } catch (e) {
      return {500: 'Error updating patient: $e'};
    }
  }

  Future<Map<String, dynamic>> getMonitoredPatient(String userId) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {"status": 401, "message": "Unauthorized: No token found", "data": null};
    }

    final url = Uri.parse('${URL().getServerURL()}/home-fetch/get-links-by-user/$userId');

    try {
      final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"});

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return {"status": 200, "message": decoded["message"] ?? "Links retrieved successfully", "data": decoded["data"]};
      } else {
        String errorMessage;

        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          errorMessage = err["detail"] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }

        return {"status": response.statusCode, "message": errorMessage, "data": null};
      }
    } catch (e) {
      return {"status": 500, "message": "Error fetching monitored patient: $e", "data": null};
    }
  }

  Future<Map<int, String>> takeIn({required PatientUserLink link}) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'Unauthorized: No token found'};
    }

    final url = Uri.parse('${URL().getServerURL()}/home-fetch/take-in/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"},
        body: jsonEncode(link.toJson()), // convert your model to JSON
      );

      try {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final message = decoded["message"] ?? "Operation completed";
        return {response.statusCode: message};
      } catch (_) {
        // fallback if response is not JSON
        return {response.statusCode: response.body};
      }
    } catch (e) {
      return {500: 'Error taking in patient: $e'};
    }
  }

  Future<bool> takeOut({required String userId, required String patientId}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      CollectionReference linkCollection = firestore.collection('patient_user_links');

      // Query for the document with matching userId and patientId
      QuerySnapshot querySnapshot = await linkCollection.where('user_id', isEqualTo: userId).where('patient_id', isEqualTo: patientId).get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first matching document (assuming there's only one)
        await linkCollection.doc(querySnapshot.docs.first.id).delete();
        return true; // Deletion successful
      } else {
        // No matching document found
        return false;
      }
    } catch (e) {
      return false; // Error occurred
    }
  }

  //* Tested
  Future<Map<String, dynamic>?> getPatientReport({required String patientId, required DateTime date}) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return null;
    }

    Map<String, dynamic> response = {};
    final DocumentSnapshot patientDocSnapshot = await FirebaseFirestore.instance.collection('patients').doc(patientId).get();

    response['patient_id'] = patientId;
    response['patient_info'] = patientDocSnapshot.data();

    if (response['patient_info'] != null) {
      Map<String, dynamic> patientInfo = response['patient_info'] as Map<String, dynamic>;
      if (patientInfo['created_at'] is Timestamp) {
        patientInfo['created_at'] = (patientInfo['created_at'] as Timestamp).toDate();
      }
    }

    DateTime queryDateStart = DateTime(date.year, date.month, date.day);
    DateTime queryDateEnd = queryDateStart.add(const Duration(days: 1));
    final QuerySnapshot mewsSnapshot =
        await FirebaseFirestore.instance
            .collection('mews')
            .where('patient_id', isEqualTo: patientId)
            .where('assessed_time', isGreaterThanOrEqualTo: Timestamp.fromDate(queryDateStart))
            .where('assessed_time', isLessThan: Timestamp.fromDate(queryDateEnd))
            .get();

    List<Map<String, dynamic>> fullReports = [];
    for (var doc in mewsSnapshot.docs) {
      Map<String, dynamic> mewsData = doc.data() as Map<String, dynamic>;
      final QuerySnapshot noteSnapshot = await FirebaseFirestore.instance.collection('inspection_notes').where('mews_id', isEqualTo: doc.id).get();

      if (noteSnapshot.docs.isNotEmpty) {
        mewsData['report_id'] = noteSnapshot.docs.first.id;
      } else {
        mewsData['report_id'] = null;
      }

      mewsData['mews_id'] = doc.id;
      mewsData['patient_id'] = patientId;

      fullReports.add(mewsData);
    }

    fullReports.sort((a, b) {
      Timestamp timeA = a['assessed_time'] as Timestamp;
      Timestamp timeB = b['assessed_time'] as Timestamp;

      return timeA.toDate().compareTo(timeB.toDate());
    });

    for (var report in fullReports) {
      if (report['assessed_time'] is Timestamp) {
        report['assessed_time'] = (report['assessed_time'] as Timestamp).toDate();
      }
    }

    response['full_reports'] = fullReports;

    return (response);
  }
}
