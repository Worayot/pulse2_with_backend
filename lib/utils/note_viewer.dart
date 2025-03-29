import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NoteViewer extends StatefulWidget {
  final String reportID;

  const NoteViewer({super.key, required this.reportID});

  @override
  _NoteViewerState createState() => _NoteViewerState();
}

class _NoteViewerState extends State<NoteViewer> {
  String date = "";
  String time = "";
  String author = "";
  String authorID = "";
  String noteText = "";
  String mewsID = "";
  String patientID = "";

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNoteData(widget.reportID);
  }

  void fetchNoteData(String reportID) async {
    try {
      // Fetch inspection note from 'inspection_notes' collection by reportID
      var noteDoc =
          await FirebaseFirestore.instance
              .collection('inspection_notes')
              .doc(reportID)
              .get();

      if (noteDoc.exists) {
        // Extract fields from the note document
        var noteData = noteDoc.data()!;

        print("reportID: ${widget.reportID}");
        print(noteData);

        // Handling the 'time' field if it's a Timestamp
        Timestamp timestamp = noteData['time'];
        DateTime noteDate = timestamp.toDate();
        // noteDate = noteDate.subtract(Duration(days: 1, hours: 7));

        setState(() {
          date = DateFormat('d/M/yyyy').format(noteDate); // Format date
          time = DateFormat('HH:mm').format(noteDate); // Format time
          authorID = noteData['audit_by'];
          mewsID = noteData['mews_id'] ?? '';
          patientID = noteData['patient_id'] ?? '';
          noteText = noteData['text'] ?? '-';

          // Set noteText to the TextField
          _noteController.text = noteText;
        });

        // Fetch the author's full name from 'users' collection based on audit_by (user_id)
        var userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .where('nurse_id', isEqualTo: authorID)
                .get();

        if (userDoc.docs.isNotEmpty) {
          var userData = userDoc.docs.first.data();
          setState(() {
            author = userData['fullname'] ?? 'Unknown';
          });
        }
      }
    } catch (e) {
      print("Error fetching note data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height / 4, left: 16, right: 16),
      child: Stack(
        children: [
          SizedBox(
            height: size.height * 0.42,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Close Button Row
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "note".tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Text Editor Field with TextController for noteText
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${"ofDate".tr()} $date ${"atTime".tr()} $time",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff565656),
                              ),
                            ),
                            Text(
                              "${"by".tr()} $author ${"id".tr()} $authorID",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: IconButton(
              icon: Icon(Icons.close, size: size.height / 25),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
