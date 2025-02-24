import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void showInfoDialog(BuildContext context, Widget widget) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
          child: Stack(
            children: [
              // Dialog content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Icon and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.circleInfo,
                            size: 25, // Size of the icon
                            color: Color(0xff3362CC), // Color of the icon
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'symbolDescription'.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Dialog content
                  widget,
                ],
              ),
              // Positioned close button inside Stack
              Positioned(
                top: -15,
                right: -15,
                child: IconButton(
                  icon: const Icon(
                    Icons.close, // The icon to display
                    color: Colors.black, // Icon color
                    size: 30, // Icon size
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
