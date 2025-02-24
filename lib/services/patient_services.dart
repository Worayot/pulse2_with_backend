import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models.dart/patient.dart';

class PatientService {
  final String baseUrl =
      'http://0.0.0.0:8000'; // Update with your actual server URL

  // Future<List<Patient>> getHomePatients() async {
  //   final Uri url = Uri.parse('$baseUrl/home-fetch/');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       // Convert the JSON data to a list of Patient objects
  //       List<Patient> patients =
  //           (data['patients'] as List)
  //               .map((patientJson) => Patient.fromJson(patientJson))
  //               .toList();
  //       return patients;
  //     } else {
  //       print('Failed to load patients: ${response.body}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching patients: $e');
  //     return [];
  //   }
  // }

  Future<bool> addPatient(Patient patient) async {
    final url = Uri.parse('$baseUrl/home-fetch/add_patient/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(patient.toJson()),
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
}
