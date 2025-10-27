import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/note.dart';
import 'package:tuh_mews/models/parameters.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'package:tuh_mews/services/url.dart';

class MEWsService {
  //* Used
  Future<Map<int, String>> addMEWs(String noteID, Parameters parameters) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/noti-fetch/add_mews/$noteID');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode(parameters));

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding MEWS: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> addNote({required String noteID, required Note note}) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      // print('No token found');
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/noti-fetch/add_notes/$noteID');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode({...note.toJson()}));

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error getting note: $e'};
    }
  }

  //* Used
  Future<Map<int, String>> addNewInspection({required InspectionNote inspectionNote}) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: 'No token found'};
    }
    final url = Uri.parse('${URL().getServerURL()}/noti-fetch/set_inspection_time/');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode({...inspectionNote.toJson()}));

      return {response.statusCode: response.body};
    } catch (e) {
      return {500: 'Error adding inspection: $e'};
    }
  }
}
