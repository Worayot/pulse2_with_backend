import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt');
  }

  Future<http.Response> authenticatedRequest(
    String url, {
    String method = 'GET', // Default to GET
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token available'); // Or handle this differently
    }

    final allHeaders = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $token', // Important: Add the token to the header
      ...headers ?? {}, // Include any additional headers
    };

    final uri = Uri.parse(url);

    switch (method) {
      case 'GET':
        return await http.get(uri, headers: allHeaders);
      case 'POST':
        return await http.post(uri, headers: allHeaders, body: body);
      case 'PUT':
        return await http.put(uri, headers: allHeaders, body: body);
      case 'DELETE':
        return await http.delete(uri, headers: allHeaders);
      // Add other methods as needed
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}

final authService = AuthService(); // Create an instance of the service
