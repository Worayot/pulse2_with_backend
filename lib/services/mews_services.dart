import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pulse/models/note.dart';
import 'package:pulse/models/parameters.dart';
import 'url.dart';

class MEWsService {
  //! Not tested
  Future<bool> getNoteByMEWsId(String mewsId) async {
    final url = Uri.parse('$baseUrl/home-fetch/delete-patient/$mewsId');

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

  //! Not tested
  Future<bool> addMEWs(String inspectionId, Parameters parameters) async {
    final url = Uri.parse('$baseUrl/noti-fetch/add_mews/$inspectionId');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(parameters),
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

  //! Not tested
  Future<bool> addNote(String noteId, Note note) async {
    final url = Uri.parse('$baseUrl/noti-fetch/add_notes/$noteId');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(note),
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
