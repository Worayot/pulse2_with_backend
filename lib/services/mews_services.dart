import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/note.dart';
import 'package:tuh_mews/models/parameters.dart';
import 'server_url.dart';

class MEWsService {
  //! Not used
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

  //* Tested
  addMEWs(String noteID, Parameters parameters) async {
    final url = Uri.parse('$baseUrl/noti-fetch/add_mews/$noteID');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(parameters),
      );

      if (response.statusCode == 200) {
        print("Successfully added MEWS: ${response.body}");
        return true; // Success
      } else {
        print("Failed to add MEWS: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error adding MEWS: $e");
      return false;
    }
  }

  //* Tested
  addNote({required String noteID, required Note note}) async {
    final url = Uri.parse('$baseUrl/noti-fetch/add_notes/$noteID');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // "note_id": noteId,
          ...note.toJson(), // Assuming Note has a `toJson()` method
        }),
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

  //* Tested
  Future<String> addNewInspection({
    required InspectionNote inspectionNote,
  }) async {
    final url = Uri.parse('$baseUrl/noti-fetch/set_inspection_time/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...inspectionNote.toJson()}),
      );

      if (response.statusCode == 200) {
        // print("Successfully adding new inspection time: ${response.body}");
        return response.body; // Success
      } else {
        // print("Failed to new inspection time: ${response.body}");
        return "Failed to new inspection time: ${response.body}";
        // return false; // Failure
      }
    } catch (e) {
      // print("Error adding new inspection time: $e");
      return '$e';
    }
  }
}
