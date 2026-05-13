import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/monitored_patient/card_model.dart';
import 'package:tuh_mews/models/patient_id_name.dart';
import 'package:tuh_mews/models/patient_user_link.dart';
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import '../models/patient.dart';
import 'package:rxdart/rxdart.dart';

class FirebasePatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PatientIdName>> streamPatientIdNames() {
    return _firestore.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return PatientIdName(id: doc.id, name: (data['fullname'] ?? '').toString());
      }).toList();
    });
  }

  /// Stream monitored patients linked to the given user ID (Real-time & Reactive)
  Stream<List<PatientModel>> fetchMonitoredPatients(String userId) {
    return _firestore.collection('patient_user_links').where('user_id', isEqualTo: userId).snapshots().switchMap((linkSnapshot) {
      // 1. If no links, return empty list immediately
      if (linkSnapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      // 2. Map each link to a Stream of the fully assembled PatientModel
      List<Stream<PatientModel?>> patientStreams =
          linkSnapshot.docs.map((doc) {
            Map<String, dynamic> linkData = doc.data();
            String patientId = linkData['patient_id'];

            // Stream A: Patient Details (uses helper below)
            var detailsStream = _fetchPatientStream(patientId);

            // Stream B: Inspection Notes with MEWS (uses helper below)
            var notesStream = _fetchInspectionNotesStream(patientId);

            // 3. Combine Link + Patient + Notes
            return Rx.combineLatest2<Map<String, dynamic>?, List<Map<String, dynamic>>, PatientModel?>(detailsStream, notesStream, (patientDetails, inspectionNotes) {
              // If patient details are missing (e.g. deleted), return null so we can filter it out
              if (patientDetails == null) return null;

              // Merge data exactly like before
              Map<String, dynamic> fullData = {...linkData, 'patient_details': patientDetails, 'inspection_notes': inspectionNotes};

              return PatientModel.fromMap(fullData);
            });
          }).toList();

      // 4. Combine all patients into one list and filter out nulls
      return CombineLatestStream.list(patientStreams).map((list) {
        return list.whereType<PatientModel>().toList();
      });
    });
  }

  /// Stream A: Real-time Patient Data
  Stream<Map<String, dynamic>?> _fetchPatientStream(String patientId) {
    return _firestore.collection('patients').doc(patientId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }

  /// Stream B: Real-time Inspection Notes (Root Collection) + Joined MEWS Data
  Stream<List<Map<String, dynamic>>> _fetchInspectionNotesStream(String patientId) {
    return _firestore
        .collection('inspection_notes') // Root collection (matches your original)
        .where('patient_id', isEqualTo: patientId)
        .snapshots()
        .switchMap((querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            return Stream.value([]);
          }

          // Create a stream for EACH note to handle the MEWS join independently
          List<Stream<Map<String, dynamic>>> noteStreams =
              querySnapshot.docs.map((doc) {
                Map<String, dynamic> noteData = doc.data();
                noteData['note_id'] = doc.id; // Inject ID (matches your original)

                String? mewsId = noteData['mews_id'];

                // Case 1: No MEWS ID -> Return note immediately
                if (mewsId == null || mewsId.isEmpty) {
                  noteData['mews'] = null;
                  return Stream.value(noteData);
                }

                // Case 2: Has MEWS ID -> Listen to MEWS document and merge
                return _firestore.collection('mews').doc(mewsId).snapshots().map((mewsDoc) {
                  if (mewsDoc.exists) {
                    noteData['mews'] = mewsDoc.data();
                  } else {
                    noteData['mews'] = null;
                  }
                  return noteData;
                });
              }).toList();

          // Combine all individual note streams into one List
          return CombineLatestStream.list(noteStreams);
        });
  }
}

class PatientService {
  //* Tested
  Future<Map<int, String>> addPatient(Patient patientData) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return {401: "User is not authenticated."};
    }

    try {
      final duplicatePatient = await db.collection("patients").where("fullname", isEqualTo: patientData.fullname.trim()).limit(1).get();

      if (duplicatePatient.docs.isNotEmpty) {
        return {409: "Patient with same fullname already exists."};
      }

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

      QuerySnapshot querySnapshot = await linkCollection.where('user_id', isEqualTo: userId).where('patient_id', isEqualTo: patientId).get();

      if (querySnapshot.docs.isNotEmpty) {
        await linkCollection.doc(querySnapshot.docs.first.id).delete();

        AlarmService().cancelAlarmsByPatientId(patientId: patientId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //* Tested
  Future<Map<String, dynamic>?> getPatientReport({required String patientId, required DateTime date}) async {
    Map<String, dynamic> response = {};
    try {
      final DocumentSnapshot patientDocSnapshot = await FirebaseFirestore.instance.collection('patients').doc(patientId).get();
      response['patient_id'] = patientId;
      response['patient_info'] = patientDocSnapshot.data();

      if (response['patient_info'] != null) {
        Map<String, dynamic> patientInfo = response['patient_info'] as Map<String, dynamic>;
        if (patientInfo['created_at'] is Timestamp) {
          patientInfo['created_at'] = (patientInfo['created_at'] as Timestamp).toDate();
        }
      }

      DateTime queryDateStart = DateTime.utc(date.year, date.month, date.day);
      DateTime queryDateEnd = queryDateStart.add(const Duration(days: 1));
      debugPrint("Fetching patient id $patientId date start $queryDateStart date end $queryDateEnd");
      final QuerySnapshot mewsSnapshot =
          await FirebaseFirestore.instance
              .collection('mews')
              .where('patient_id', isEqualTo: patientId)
              .where('assessed_time', isGreaterThanOrEqualTo: Timestamp.fromDate(queryDateStart))
              .where('assessed_time', isLessThan: Timestamp.fromDate(queryDateEnd))
              .orderBy('assessed_time')
              .get();
      debugPrint("Docs found: ${mewsSnapshot.docs.length}");

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
    } catch (e) {
      return response;
    }
  }
}
