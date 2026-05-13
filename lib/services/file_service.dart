import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileService {
  static Future<File?> pickExcelFile() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }
}
