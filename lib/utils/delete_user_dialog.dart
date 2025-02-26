import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/services/user_services.dart';

void showDeleteUserDialog(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for dialog
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white, // Set background color
            borderRadius: BorderRadius.circular(15), // Add border radius
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Adjust dialog height based on content
            children: [
              const SizedBox(height: 20),
              const Icon(
                FontAwesomeIcons.userMinus,
                size: 50,
                color: Color(0xff0B4870),
              ),
              const SizedBox(height: 20),
              Text(
                "deleteUserConfirmation".tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3362CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "cancel".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () {
                      UserServices().deleteUser(userId);
                      Navigator.of(context).pop(); // Close the current dialog
                      _showFinalConfirmationDialog(
                        context,
                      ); // Show confirmation dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE45B5B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "confirm".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showFinalConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for dialog
        ),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15), // Add border radius
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Adjust dialog height based on content
            children: [
              const Icon(
                FontAwesomeIcons.solidCircleCheck,
                size: 50,
                color: Color(0xff10AC51),
              ),
              const SizedBox(height: 20),
              Text(
                "userDeletedSuccessfully".tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
