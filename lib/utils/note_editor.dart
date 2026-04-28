import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tuh_mews/models/note.dart';
import 'package:tuh_mews/services/mews_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditor extends StatefulWidget {
  final String note;
  final String noteID;
  final VoidCallback onPop;

  const NoteEditor({super.key, required this.note, required this.noteID, required this.onPop});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _noteController;
  String myUserID = '';

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myUserID = prefs.getString('nurseID') ?? "N/A";
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Close Button Row
                    Align(alignment: Alignment.center, child: Text("note".tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 60),

                    // Text Editor Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(controller: _noteController, decoration: const InputDecoration(border: UnderlineInputBorder())),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await MEWsService().addNote(noteID: widget.noteID, note: Note(text: _noteController.text.trim(), auditorID: myUserID));

                              if (!context.mounted) return;

                              Navigator.pop(context);
                              widget.onPop();

                              showResponseDialog(context: context, title: "success".tr(), message: "noteSavedSuccess".tr(), isSuccess: true);
                            } catch (e) {
                              if (!context.mounted) return;

                              showResponseDialog(context: context, title: "error".tr(), message: "noteSavedFailed".tr(), isSuccess: false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff407BFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text('saveAgain'.tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

void showResponseDialog({required BuildContext context, required String title, required String message, required bool isSuccess}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 48),
              const SizedBox(height: 12),

              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),

              const SizedBox(height: 8),

              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: isSuccess ? Colors.green : Colors.red, foregroundColor: Colors.white),
                  child: Text("ok".tr()),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
