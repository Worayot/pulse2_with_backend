import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoteViewer extends StatelessWidget {
  const NoteViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String date = "7/11/2567";
    String time = "9:30";
    String author = "วรยศ เลี่ยมแก้ว";
    String authorID = "112203";

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
                                    fontSize: 12, color: Color(0xff565656))),
                            Text("${"by".tr()} $author ${"id".tr()} $authorID",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black)),
                          ],
                        )
                      ],
                    )
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
