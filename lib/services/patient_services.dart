import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'url.dart';
import '../models/patient.dart';

class PatientService {
  //* Tested
  Future<bool> addPatient(Patient patientData) async {
    final url = Uri.parse('$baseUrl/home-fetch/add_patient/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(patientData.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to add patient: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error adding patient: $e");
      return false;
    }
  }

  //! Not tested
  Future<bool> deletePatient(String patientId) async {
    final url = Uri.parse('$baseUrl/home-fetch/delete-patient/$patientId');

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientId),
      );

      if (response.statusCode == 200) {
        print("Successfully deleted patient: ${response.body}");
        return true; // Success
      } else {
        print("Failed to deleting patient: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error deleting patient: $e");
      return false;
    }
  }

  //* Tested
  updatePatient(String patientId, Patient patientData) async {
    final url = Uri.parse('$baseUrl/home-fetch/update_patient/$patientId');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(patientData.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to update patient: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error updating patient: $e");
      return false;
    }
  }

  //! Not tested
  Future<Map<String, dynamic>?> getMonitoredPatient(String userId) async {
    final url = Uri.parse('$baseUrl/home-fetch/get-links-by-user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        // Parse the response body if it's JSON
        Map<String, dynamic> responseData = jsonDecode(response.body);
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

  //! Not tested
  Future<bool> takeIn(String userId, String patientId) async {
    final url = Uri.parse('$baseUrl/home-fetch/take-in');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'patient_id': patientId, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to take in patient: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error taking in patient: $e");
      return false;
    }
  }

  //! Not tested
  Future<bool> takeOut(String userId, String patientId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      CollectionReference linkCollection = firestore.collection(
        'patient_user_links',
      );

      // Query for the document with matching userId and patientId
      QuerySnapshot querySnapshot =
          await linkCollection
              .where('userId', isEqualTo: userId)
              .where('patientId', isEqualTo: patientId)
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

  // Example usage:
  // String userId = "someUserId";
  // String patientId = "somePatientId";
  // takeOut(userId, patientId).then((success) {
  //   if (success) {
  //     print("Patient removed successfully.");
  //   } else {
  //     print("Patient removal failed (or patient not found).");
  //   }
  // });

  //! Not tested
  Future<bool> getPatientData(String patientId) async {
    final url = Uri.parse('$baseUrl/home-fetch/get_patient/$patientId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientData.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to get patient data: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error getting patient data: $e");
      return false;
    }
  }

  //! Not tested
  Future<bool> getPatientReport(String patientId) async {
    final url = Uri.parse('$baseUrl/home-fetch/report/$patientId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientData.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to get patient report: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error getting patient report: $e");
      return false;
    }
  }

  //! Not tested
  Future<bool> loadMonitoredPatient(String userId) async {
    final url = Uri.parse('$baseUrl/noti-fetch/load_take_in/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientData.toJson()),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to get patient report: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error getting patient report: $e");
      return false;
    }
  }
}
