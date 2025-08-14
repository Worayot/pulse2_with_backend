import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final secureStorage = const FlutterSecureStorage();

  Future<void> write({required String key, required String value, Duration? expiry}) async {
    await secureStorage.write(key: key, value: value);

    if (expiry != null) {
      final expiryTimestamp = DateTime.now().add(expiry).millisecondsSinceEpoch.toString();
      await secureStorage.write(key: '${key}_expiry', value: expiryTimestamp);
    }
  }

  Future<String?> read({required String key}) async {
    final expiryString = await secureStorage.read(key: '${key}_expiry');

    if (expiryString != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
      if (DateTime.now().isAfter(expiry)) {
        // Expired: delete both key and expiry
        await delete(key: key);
        return null;
      }
    }

    return await secureStorage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await secureStorage.delete(key: key);
    await secureStorage.delete(key: '${key}_expiry');
  }
}
