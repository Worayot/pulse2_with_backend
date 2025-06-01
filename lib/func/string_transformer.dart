import 'dart:convert';
import 'package:crypto/crypto.dart';

class StringTransformer {
  /// Returns a deterministic SHA256 hex string from the input
  String generateFrom(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Returns a smaller deterministic integer ID (32-bit) from the input string
  int generateID(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);

    // Use first 4 bytes of the digest to form a 32-bit int
    int id = digest.bytes
        .sublist(0, 4)
        .fold<int>(0, (prev, elem) => (prev << 8) | elem);

    return id % 1000000;
  }
}
