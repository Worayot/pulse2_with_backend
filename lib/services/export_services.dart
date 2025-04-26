import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:tuh_mews/services/server_url.dart';
import 'package:tuh_mews/services/url.dart';
import 'package:uuid/uuid.dart';

class ExportServices {
  Future<bool> export(List<String> patientIds) async {
    final _storage = FlutterSecureStorage();

    String? idToken = await _storage.read(key: 'id_token');

    if (idToken == null) {
      return false;
    }
    final url = Uri.parse(
      '${URL().getServerURL()}/expt-fetch/get_report_excel',
    ); // Corrected URL

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({"patient_ids": patientIds}), // Corrected body
      );

      if (response.statusCode == 200) {
        print(response.body);
        return await _saveAndOpenFile(response.bodyBytes); // Corrected body
      } else {
        print("Failed to receive note: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error getting note: $e");
      return false;
    }
  }

  Future<bool> _saveAndOpenFile(List<int> excelData) async {
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
          print('Error: Could not get directory.');
          return false;
        }

        final uuid = Uuid(); // Generate unique id
        final uniqueFileName =
            'all_patients_report_${uuid.v4()}.xlsx'; // Create unique file name
        final filePath = '${directory.path}/$uniqueFileName';
        final file = File(filePath);
        await file.writeAsBytes(excelData);

        final result = await OpenFile.open(filePath);
        print('File opened: ${result.message}');
        return true;
      } catch (e) {
        print('Error saving/opening file: $e');
        return false;
      }
    } else {
      print('Storage permission denied.');
      return false;
    }
  }
}
