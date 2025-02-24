// import 'package:flutter/material.dart';
// import 'sse_service.dart';

// class PatientListPage extends StatefulWidget {
//   @override
//   _PatientListPageState createState() => _PatientListPageState();
// }

// class _PatientListPageState extends State<PatientListPage> {
//   late FirestoreSSEService sseService;
//   late Stream<List<Map<String, dynamic>>> patientStream;

//   @override
//   void initState() {
//     super.initState();
//     sseService = FirestoreSSEService(baseUrl: "http://127.0.0.1:8000");
//     patientStream = sseService.listenToPatients();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Real-Time Patients")),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: patientStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text("No patients found"));
//           }

//           final patients = snapshot.data!;
//           return ListView.builder(
//             itemCount: patients.length,
//             itemBuilder: (context, index) {
//               final patient = patients[index];
//               return ListTile(
//                 title: Text(patient['fullname'] ?? 'Unknown'),
//                 subtitle: Text("ID: ${patient['id']}"),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
