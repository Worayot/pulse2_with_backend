import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/services/patient_services.dart';

class TemplateService {
  static final patientImportHeaders = ['Name', 'Surname', 'Age', 'Gender', 'Hospital Number', 'Bed Number', 'Ward'];

  static Future<void> createImportPatientTemplate() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Template'];

    for (int i = 0; i < patientImportHeaders.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(patientImportHeaders[i]);
    }

    final directory = await getApplicationDocumentsDirectory();

    String filePath = '${directory.path}/import_patient_template.xlsx';

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    debugPrint('Excel file saved at: $filePath');
  }

  static Future<List<Map<int, String>>> importPatientsFromExcel(File file) async {
    final bytes = file.readAsBytesSync();

    final excel = Excel.decodeBytes(bytes);

    final Sheet? sheet = excel.tables['Template'];

    if (sheet == null) {
      return [
        {400: 'Template sheet not found.'},
      ];
    }

    if (sheet.maxRows < 2) {
      return [
        {400: 'No patient data found in the template.'},
      ];
    }

    if (sheet.maxColumns < 7) {
      return [
        {400: 'Template format is incorrect. Expected at least 7 columns.'},
      ];
    }

    List<Map<int, String>> results = [];

    for (int row = 1; row < sheet.maxRows; row++) {
      try {
        final name = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value?.toString() ?? '';
        final surname = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value?.toString() ?? '';
        final age = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value?.toString() ?? '';
        final gender = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value?.toString() ?? '';
        final hospitalNumber = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value?.toString() ?? '';
        final bedNumber = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value?.toString() ?? '';
        final ward = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value?.toString() ?? '';

        // Skip
        if (name.isEmpty &&
            surname.isEmpty &&
            (age.isEmpty || (int.tryParse(age) ?? -1) > 120 && ((int.tryParse(age) ?? -1) < 1)) &&
            gender.isEmpty &&
            hospitalNumber.isEmpty &&
            bedNumber.isEmpty &&
            ward.isEmpty) {
          continue;
        }

        final patient = Patient(fullname: '$name $surname', age: age, gender: gender, hospitalNumber: hospitalNumber, ward: ward, bedNumber: bedNumber);

        final result = await PatientService().addPatient(patient);

        results.add(result);
      } catch (e) {
        results.add({500: 'Error importing row ${row + 1}: $e'});
      }
    }

    return results;
  }

  static Future<void> validatePatientTemplate(Sheet sheet) async {
    const int maxRows = 200;

    final expectedHeaders = patientImportHeaders;

    for (int col = 0; col < expectedHeaders.length; col++) {
      final cellValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value?.toString().trim() ?? '';

      if (cellValue != expectedHeaders[col]) {
        throw Exception(
          'Invalid template format.\n'
          'Expected column "${expectedHeaders[col]}" '
          'at position ${col + 1}, '
          'but found "$cellValue".',
        );
      }
    }

    int actualDataRows = 0;

    for (int row = 1; row < sheet.maxRows; row++) {
      bool hasData = false;

      for (int col = 0; col < expectedHeaders.length; col++) {
        final value = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)).value?.toString().trim() ?? '';

        if (value.isNotEmpty) {
          hasData = true;
          break;
        }
      }

      if (hasData) {
        actualDataRows++;
      }
    }

    if (actualDataRows > maxRows) {
      throw Exception(
        'Maximum $maxRows patients allowed.\n'
        'Found $actualDataRows rows.',
      );
    }
  }
}
