import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'url.dart';
import '../models.dart/patient.dart';

class ExportServices {
  //! Not tested
  Future<bool> export(List<String> patientIds) async {
    final url = Uri.parse(
      '$baseUrl/expt-fetch/get_report_excel/{"patient_ids": $patientIds}',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        // body: jsonEncode(patientId),
      );

      if (response.statusCode == 200) {
        print("Successfully received note: ${response.body}");
        return true; // Success
      } else {
        print("Failed to receive note: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error getting note: $e");
      return false;
    }
  }
}
