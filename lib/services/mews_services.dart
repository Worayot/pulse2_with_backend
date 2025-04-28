import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/note.dart';
import 'package:tuh_mews/models/parameters.dart';
import 'package:tuh_mews/services/url.dart';

class MEWsService {
  //! Not used
  Future<Map<int, String>> getNoteByMEWsId(String mewsId) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      print('No token found');
      return {401: 'No token found'}; // Return a map with status code
    }

    final url = Uri.parse(
      '${URL().getServerURL()}/home-fetch/delete-patient/$mewsId',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
      );

      return {
        response.statusCode: response.body,
      }; // Return map with status code and body
    } catch (e) {
      return {500: 'Error getting note: $e'}; // Return map for error
    }
  }

  //* Used
  Future<Map<int, String>> addMEWs(String noteID, Parameters parameters) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/noti-fetch/add_mews/$noteID',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(parameters),
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding MEWS: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> addNote({
    required String noteID,
    required Note note,
  }) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      // print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/noti-fetch/add_notes/$noteID',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({...note.toJson()}),
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error getting note: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> addNewInspection({
    required InspectionNote inspectionNote,
  }) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/noti-fetch/set_inspection_time/',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({...inspectionNote.toJson()}),
      );

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding inspection: $e'};
    }
  }
}
