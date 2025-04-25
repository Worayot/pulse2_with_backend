import 'dart:convert';
import 'package:crypto/crypto.dart';

class StringTransformer {
  /// Returns a deterministic hash from the input
  String generateFrom(String input) {
    var bytes = utf8.encode(input); // Convert to bytes
    var digest = sha256.convert(bytes); // Create SHA256 hash
    return digest.toString(); // Return the hex string
  }
}
