import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

Future<Map<String, dynamic>> fetchLatestPatientData(String patientId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    CollectionReference noteCollection = firestore.collection(
      'inspection_notes',
    );

    QuerySnapshot noteSnapshot =
        await noteCollection
            .where('patient_id', isEqualTo: patientId)
            .orderBy('time', descending: true)
            .limit(1)
            .get();

    if (noteSnapshot.docs.isNotEmpty) {
      DocumentSnapshot latestNoteDoc = noteSnapshot.docs.first;
      Map<String, dynamic> noteData =
          latestNoteDoc.data() as Map<String, dynamic>;

      String mewsId = noteData['mews_id'];
      Timestamp time = noteData['time']; // Get the Timestamp

      // Convert Timestamp to a formatted date string
      String formattedTime = DateFormat('HH:mm').format(time.toDate());

      if (mewsId.isNotEmpty) {
        try {
          // Directly create a reference to the mews document by ID
          DocumentSnapshot mewsDoc = await firestore.doc('mews/$mewsId').get();

          if (mewsDoc.exists) {
            Map<String, dynamic> mewsData =
                mewsDoc.data() as Map<String, dynamic>;
            return {'mews': mewsData['mews'] ?? '-', 'time': formattedTime};
          } else {
            // print(
            //   'Patient ID: $patientId, No MEWS document found with ID: $mewsId',
            // );
            return {'mews': '-', 'time': formattedTime};
          }
        } catch (mewsError) {
          print(
            'Error fetching MEWS document for patient $patientId, mews_id $mewsId: $mewsError',
          );
          return {'mews': '-', 'time': formattedTime};
        }
      } else {
        print('Patient ID: $patientId, mews_id is missing or empty.');
        return {'mews': '-', 'time': formattedTime};
      }
    } else {
      // print('Patient ID: $patientId, No note data found.');
      return {'mews': '-', 'time': '-'};
    }
  } catch (noteError) {
    print('Error fetching Note data for patient $patientId: $noteError');
    return {'mews': '-', 'time': '-'};
  }
}
