import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

Future<String?> getSessionCookie() async {
  try {
    String? sessionCookie = await _storage.read(key: 'session_cookie');
    return sessionCookie;
  } catch (e) {
    return null;
  }
}
