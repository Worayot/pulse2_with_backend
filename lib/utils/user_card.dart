import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/utils/action_button.dart';
import 'package:tuh_mews/utils/delete_user_dialog.dart';
import 'package:tuh_mews/utils/edit_user_form.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final bool renderRemoveButton;
  const UserCard({
    super.key,
    required this.user,
    required this.renderRemoveButton,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: const Color(0xffE0EAFF),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${"role".tr()} ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                ),
                                TextSpan(
                                  text: "${user.role.tr()} ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${"nurseID".tr()} ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                ),
                                TextSpan(
                                  text: user.nurseId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -1,
          top: 0,
          bottom: 8,
          child: IgnorePointer(
            child: SizedBox(
              height: 180, // Adjust the height
              width: 180, // Adjust the width
              child: Image.asset(
                "assets/images/therapy3.png",
                fit: BoxFit.contain, // Ensures the image fits within the box
              ),
            ),
          ),
        ),
        if (renderRemoveButton)
          Positioned(
            top: 0,
            bottom: 0,
            right: 13,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  width: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff3362CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      // fixedSize: const Size(10, 30),
                      elevation: 0,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditUserForm(user: user);
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 0,
                      ),
                      child: Text(
                        'edit'.tr(), // Replace with your text
                        style: const TextStyle(
                          color: Color(0xff3362CC),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                buildActionButton(
                  FontAwesomeIcons.userMinus,
                  () {
                    print('Attempt to delete UID: ${user.nurseId}');
                    showDeleteUserDialog(context, user.nurseId);
                  },
                  Colors.white,
                  const Color(0xffE45B5B),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
