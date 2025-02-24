import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoteAdder extends StatelessWidget {
  final VoidCallback onSave;

  const NoteAdder({
    super.key,
    required this.onSave,
  });

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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff407BFF), // Blue background
                              foregroundColor: Colors.white, // White text
                              // side: const BorderSide(
                              //   color: Colors.white, // White border color
                              //   width: 1, // Border width
                              // ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12), // Padding
                            ),
                            child: Text(
                              'save'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
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
          )
        ],
      ),
    );
  }
}
