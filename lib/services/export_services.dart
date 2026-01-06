import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuh_mews/services/session_service.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:tuh_mews/services/url.dart';

class ExportServices {
  Future<Map<int, String>> export(List<String> patientIds) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: "Unauthorized: Invalid or missing token."};
    }

    final url = Uri.parse('${URL().getServerURL()}/expt-fetch/get_report_excel');
    debugPrint('patients: $patientIds');
    debugPrint("url: $url");
    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode({"patient_ids": patientIds}));

      debugPrint("response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return await _saveFile(response.bodyBytes);
      } else {
        return {401: "Token expired"};
      }
    } catch (e) {
      return {500: "Internal Server Error: $e"};
    }
  }

  Future<Map<int, String>> _saveFile(List<int> excelData) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        final directories = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        directory = directories?.first;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return {500: "Could not locate directory"};
      }

      final uuid = Uuid();
      final uniqueFileName = 'all_patients_report_${uuid.v4()}.xlsx';
      final filePath = '${directory.path}/$uniqueFileName';
      final file = File(filePath);
      await file.writeAsBytes(excelData);

      return {200: filePath};
    } catch (e) {
      return {500: "Internal Server Error: $e"};
    }
  }
}
