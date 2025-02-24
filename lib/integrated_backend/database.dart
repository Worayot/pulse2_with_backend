import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Database {
  FirebaseApp? _firebaseApp; // Store the FirebaseApp instance
  FirebaseDatabase? _database; // Store the FirebaseDatabase instance

  Future<FirebaseDatabase> getDb() async {
    if (_database != null) {
      return _database!; // Return cached instance if available
    }

    try {
      _firebaseApp ??=
          await Firebase.initializeApp(); // Initialize if not already done

      _database = FirebaseDatabase.instanceFor(
        app: _firebaseApp!,
        databaseURL: 'https://your-realtime-database-url.firebaseio.com/',
      );

      return _database!;
    } catch (e) {
      print('Error initializing Firebase Database: $e');
      rethrow; // Re-throw the error to be handled by the caller
    }
  }
}
