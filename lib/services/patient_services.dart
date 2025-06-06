import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/patient_user_link.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';
import 'server_url.dart';
import '../models/patient.dart';

class FirebasePatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream monitored patients linked to the given user ID
  Stream<List<Map<String, dynamic>>> fetchMonitoredPatients(String userId) {
    return _firestore
        .collection('patient_user_links')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .asyncMap((querySnapshot) async {
          List<Map<String, dynamic>> monitoredPatients = [];

          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              Map<String, dynamic> patientData = doc.data();
              String patientId = patientData['patient_id'];

              // Fetch patient details from the 'patients' collection
              Map<String, dynamic>? patientDetails = await fetchPatientData(
                patientId,
              );

              // Fetch inspection notes for this patient
              List<Map<String, dynamic>> inspectionNotes =
                  await fetchInspectionNotes(patientId);

              // Add patient details and inspection notes to the monitored patient data
              if (patientDetails != null) {
                patientData['patient_details'] = patientDetails;
              }
              patientData['inspection_notes'] = inspectionNotes;
              monitoredPatients.add(patientData);
            }

            print(
              "Successfully retrieved monitored patients with inspection notes and MEWS data.",
            );
          } else {
            print("No monitored patient data found.");
          }

          return monitoredPatients;
        });
  }

  /// Fetch patient data from the 'patients' collection
  Future<Map<String, dynamic>?> fetchPatientData(String patientId) async {
    try {
      final DocumentSnapshot docSnapshot =
          await _firestore.collection('patients').doc(patientId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print("No patient data found for patientId $patientId");
        return null; // No patient data found
      }
    } catch (e) {
      print("Error fetching patient data for patientId $patientId: $e");
      return null; // Error fetching patient data
    }
  }

  /// Fetch inspection notes for a specific patient
  Future<List<Map<String, dynamic>>> fetchInspectionNotes(
    String patientId,
  ) async {
    List<Map<String, dynamic>> inspectionNotes = [];

    try {
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection('inspection_notes')
              .where('patient_id', isEqualTo: patientId)
              .get();

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
      print("Error fetching inspection notes for patient $patientId: $e");
    }

    return inspectionNotes;
  }

  /// Fetch MEWS data using mews_id
  Future<Map<String, dynamic>?> fetchMewsData(String mewsId) async {
    try {
      final DocumentSnapshot docSnapshot =
          await _firestore.collection('mews').doc(mewsId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        return null; // No MEWS data found
      }
    } catch (e) {
      print("Error fetching MEWS data for mews_id $mewsId: $e");
      return null;
    }
  }
}

class PatientService {
  //* Tested
  Future<Map<int, String>> addPatient(Patient patientData) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/home-fetch/add_patient/');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(patientData.toJson()),
      );
      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding patient: $e'};
    }
  }

  //* Tested
  Future<Map<int, String>> deletePatient(String patientId) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/delete-patient/$patientId',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error deleting patient: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> updatePatient(
    String patientId,
    Patient patientData,
  ) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/update_patient/$patientId',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(patientData.toJson()),
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error updating patient: $e'};
    }
  }

  //* Tested
  Future<Map<String, dynamic>?> getMonitoredPatient(String userId) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return null;
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/get-links-by-user/$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body if it's JSON
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // print(responseData);
        return responseData; // Return the parsed data
      } else {
        print("Failed to get monitored patient: ${response.body}");
        return null; // Return null on failure
      }
    } catch (e) {
      print("Error monitoring patient: $e");
      return null; // Return null in case of error
    }
  }

  Future<Map<int, String>> takeIn({required PatientUserLink link}) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/home-fetch/take-in/');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(link.toJson()), // Only one jsonEncode needed
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error taking in patient: $e'};
    }
  }

  Future<bool> takeOut({
    required String userId,
    required String patientId,
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      CollectionReference linkCollection = firestore.collection(
        'patient_user_links',
      );

      // Query for the document with matching userId and patientId
      QuerySnapshot querySnapshot =
          await linkCollection
              .where('user_id', isEqualTo: userId)
              .where('patient_id', isEqualTo: patientId)
              .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first matching document (assuming there's only one)
        await linkCollection.doc(querySnapshot.docs.first.id).delete();
        return true; // Deletion successful
      } else {
        // No matching document found
        return false; // Or handle as you see fit: document not found, so no deletion happened.
      }
    } catch (e) {
      print("Error taking out patient: $e");
      return false; // Error occurred
    }
  }

  //! Not tested
  Future<Map<int, String>> getPatientData(String patientId) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/get_patient/$patientId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error getting patient data: $e'};
    }
  }

  //* Tested
  Future<Map<String, dynamic>?> getPatientReport(String patientId) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/report/$patientId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      if (response.statusCode == 200) {
        // 👇 Decode response body as UTF-8 explicitly
        final decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> responseData = jsonDecode(decodedBody);

        return responseData;
      } else {
        print("Failed to get patient report: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error getting patient report: $e");
      return null; // Error, no data to return
    }
  }

  //! Not tested
  Future<Map<int, String>> loadMonitoredPatient(String userId) async {
    // final _storage = FlutterSecureStorage();
    // String? idToken = await _storage.read(key: 'id_token');
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/noti-fetch/load_take_in/$userId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error loading monitored patient: $e'};
    }
  }
}
