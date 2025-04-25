import 'dart:convert';
import 'package:crypto/crypto.dart';

class StringTransformer {
  /// Returns a deterministic SHA256 hex string from the input
  String generateFrom(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString(); // SHA256 hex string (64 chars)
  }

  /// Returns a deterministic integer ID from the input string
  int generateID(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);

    // Convert first 8 bytes of the digest to a 64-bit integer
    int id = digest.bytes
        .sublist(0, 8)
        .fold<int>(0, (prev, elem) => (prev << 8) | elem);

    // print("input: $input");
    // print("Generated ID: $id");

    return id;
  }
}
