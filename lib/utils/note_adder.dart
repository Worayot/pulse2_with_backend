import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pulse/models/note.dart';
import 'package:pulse/services/mews_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteAdder extends StatefulWidget {
  final String noteID;
  final VoidCallback onPop;

  const NoteAdder({super.key, required this.noteID, required this.onPop});

  @override
  _NoteAdderState createState() => _NoteAdderState();
}

class _NoteAdderState extends State<NoteAdder> {
  String auditor = '';
  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      auditor = prefs.getString('nurseID') ?? "N/A";
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  // Controller for the TextField
  final TextEditingController _controller = TextEditingController();

  // To store the text when the user saves
  String text = '';

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

                    // Text Editor Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: _controller, // Set the controller here
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            text = value; // Update the text as user types
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add the note with the text from the controller
                            MEWsService().addNote(
                              noteID: widget.noteID,
                              note: Note(text: text, auditorID: auditor),
                            );
                            Navigator.pop(
                              context,
                            ); // Close the screen after saving
                            widget.onPop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xff407BFF,
                            ), // Blue background
                            foregroundColor: Colors.white, // White text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ), // Padding
                          ),
                          child: Text(
                            'save'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
