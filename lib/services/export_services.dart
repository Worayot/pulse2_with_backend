import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
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
        return await _saveAndOpenFile(response.bodyBytes);
      } else {
        return {401: "Token expired"};
      }
    } catch (e) {
      return {500: "Internal Server Error: $e"};
    }
  }

  Future<Map<int, String>> _saveAndOpenFile(List<int> excelData) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        bool permissionGranted = await _requestStoragePermissions();
        if (!permissionGranted) {
          return {403: "Forbidden: Storage permission denied."};
        }

        final directories = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        directory = directories?.first;
        if (directory == null) {
          return {500: "Internal Server Error: Could not get directory."};
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        return {500: "Unsupported platform."};
      }

      final uuid = Uuid();
      final uniqueFileName = 'all_patients_report_${uuid.v4()}.xlsx';
      final filePath = '${directory.path}/$uniqueFileName';
      final file = File(filePath);
      await file.writeAsBytes(excelData);

      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        return {200: "File saved and opened successfully."};
      } else {
        return {500: "Error opening file: ${result.message}"};
      }
    } catch (e) {
      return {500: "Internal Server Error: $e"};
    }
  }

  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      // For Android 11+ request MANAGE_EXTERNAL_STORAGE permission
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      } else {
        // Open app settings for manual enablement
        await openAppSettings();
        return false;
      }
    }
    // iOS does not need special permission for documents directory
    return true;
  }
}
