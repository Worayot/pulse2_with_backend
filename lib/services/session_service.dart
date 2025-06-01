import 'package:firebase_auth/firebase_auth.dart';

class SessionService {
  Future<String?> getIdToken() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      String? idToken = await user.getIdToken(true);
      return idToken;
    } catch (e) {
      return null;
    }
  }
}
