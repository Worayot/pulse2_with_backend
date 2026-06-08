import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:tuh_mews/services/session_service.dart';
import 'dart:convert';
import 'package:tuh_mews/services/url.dart';

class ExportServices {
  Future<Map<int, String>> export(List<String> patientIds, {bool Function()? onCheckCancel}) async {
    String? idToken = await SessionService().getIdToken();

    if (idToken == null) {
      return {401: "Unauthorized: Invalid or missing token."};
    }

    // Check before starting the request
    if (onCheckCancel != null && onCheckCancel()) return {499: "Canceled"};

    final url = Uri.parse('${URL().getServerURL()}/expt-fetch/get_report_excel');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json", "Authorization": "Bearer $idToken"}, body: jsonEncode({"patient_ids": patientIds}));

      // Check after request finishes (User might have tapped cancel while waiting for the server)
      if (onCheckCancel != null && onCheckCancel()) return {499: "Canceled"};

      if (response.statusCode == 200) {
        if (onCheckCancel != null && onCheckCancel()) return {499: "Canceled"};
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
      final fileName = 'patient_report_${DateTime.now().millisecondsSinceEpoch}';
      final savedPath = await FileSaver.instance.saveAs(name: fileName, bytes: Uint8List.fromList(excelData), fileExtension: 'xlsx', mimeType: MimeType.microsoftExcel);

      if (savedPath == null) {
        return {499: "User canceled the save dialog"};
      }

      return {200: savedPath};
    } catch (e) {
      return {500: "Internal Server Error: $e"};
    }
  }
}
