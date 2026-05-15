import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/state/secure_storage/secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final authenticationProvider = Provider<AuthenticationService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthenticationService(secureStorage);
});

class AuthenticationService {
  final SecureStorage secureStorage;

  AuthenticationService(this.secureStorage);

  Future<bool> isAuthenticated() async {
    final sessionCookie = await secureStorage.read(key: 'session_cookie') ?? '';

    return sessionCookie.isNotEmpty;
  }
}
