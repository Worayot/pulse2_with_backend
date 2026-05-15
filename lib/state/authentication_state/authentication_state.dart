import 'package:tuh_mews/state/secure_storage/secure_storage.dart';

class AuthenticationState {
  final secureStorage = SecureStorage();

  Future<bool> isAuthenticated() async {
    final String sessionCookie = await secureStorage.read(key: 'session_cookie') ?? '';
    return sessionCookie.isNotEmpty;
  }
}
