import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:tuh_mews/services/server_url.dart';
import 'package:tuh_mews/services/url.dart';

class ExportServices {
  Future<Map<int, String>> export(List<String> patientIds) async {
    final _storage = FlutterSecureStorage();
    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return {401: "Unauthorized: Invalid or missing token."};
    }

    final url = Uri.parse(
      '${URL().getServerURL()}/expt-fetch/get_report_excel',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({"patient_ids": patientIds}),
      );

      if (response.statusCode == 200) {
        return await _saveAndOpenFile(response.bodyBytes, response.statusCode);
      } else {
        return {401: "Token expired"};
      }
    } catch (e) {
      // print("Error getting note: $e");
      return {500: "Internal Server Error: $e"};
    }
  }

  Future<Map<int, String>> _saveAndOpenFile(
    List<int> excelData,
    int statusCode,
  ) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          // print('Error: Could not get directory.');
          return {500: "Internal Server Error: Could not get directory."};
        }

        final uuid = Uuid();
        final uniqueFileName = 'all_patients_report_${uuid.v4()}.xlsx';
        final filePath = '${directory.path}/$uniqueFileName';
        final file = File(filePath);
        await file.writeAsBytes(excelData);

        final result = await OpenFile.open(filePath);
        // print('File opened: ${result.message}');
        if (result.type == ResultType.done) {
          return {200: "File saved and opened successfully."};
        } else {
          return {500: "Error opening file: ${result.message}"};
        }
      } catch (e) {
        // print('Error saving/opening file: $e');
        return {500: "Internal Server Error: $e"};
      }
    } else {
      // print('Storage permission denied.');
      return {403: "Forbidden: Storage permission denied."};
    }
  }
}
