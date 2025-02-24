import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pulse/integrated_backend/get_session_cookie.dart';

class FirestoreDataScreen extends StatefulWidget {
  @override
  _FirestoreDataScreenState createState() => _FirestoreDataScreenState();
}

class _FirestoreDataScreenState extends State<FirestoreDataScreen> {
  // CollectionReference is used to interact with a specific collection
  CollectionReference patients = FirebaseFirestore.instance.collection(
    'patients',
  ); // Replace 'patients' with your collection name

  String? sessionCookie;

  // Function to retrieve the session cookie
  Future<void> getSession() async {
    sessionCookie = await getSessionCookie();
    if (sessionCookie != null) {
      print("Session Cookie: $sessionCookie");
    } else {
      print("No session cookie found.");
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch session cookie when the screen is initialized
    getSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firestore Data')),
      body: StreamBuilder<QuerySnapshot>(
        // Use StreamBuilder for real-time updates
        stream:
            patients
                .snapshots(), // Listen to changes in the 'patients' collection
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Show loading indicator
          }

          // snapshot.data!.docs contains the documents in the collection
          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()
                          as Map<String, dynamic>; // Get the data as a map

                  // Access the data fields using the keys (e.g., 'fullname')
                  String patientName =
                      data['fullname'] ??
                      ''; // Provide default values in case a field is missing

                  return ListTile(
                    title: Text(patientName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$data'),
                        // ... display other fields
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
