import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/models/user.dart';
import 'package:pulse/services/user_services.dart';
import 'package:pulse/universal_setting/sizes.dart';
import 'package:pulse/utils/info_text_field.dart';

class AddUserForm extends StatefulWidget {
  const AddUserForm({super.key});

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nurseIDController = TextEditingController();

  String selectedRole = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    nurseIDController.dispose();
    super.dispose();
  }

  void submitData() {
    if (_isSubmitting) {
      // If already submitting, do nothing
      return;
    }

    // Set _isSubmitting to true to prevent double submission
    setState(() {
      _isSubmitting = true;
    });

    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String nurseID = nurseIDController.text.trim();

    if (name.isEmpty ||
        surname.isEmpty ||
        selectedRole.isEmpty ||
        nurseID.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning".tr()),
            content: Text("plsFillInAllTheFields".tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // User confirmed
                },
                child: Text("ok".tr()),
              ),
            ],
          );
        },
      );

      // Set _isSubmitting back to false to enable further submissions
      setState(() {
        _isSubmitting = false;
      });
      return;
    } else {
      // Only pop once if the form submission is successful
      if (mounted) {
        Navigator.pop(context); // Pop the current form
      }

      String password = nurseID.padLeft(6, '0');

      // Uncomment the following line when you want to add user data
      UserServices().addUser(
        User(
          fullname: '$name $surname',
          nurseId: nurseID,
          password: password,
          role: selectedRole,
        ),
      );

      // Set _isSubmitting back to false after submission completes
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    TextWidgetSize tws = TextWidgetSize(context: context);

    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: size.height * 0.46,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                child: Row(
                  children: [
                    Text(
                      "addUserData".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: infoTextField(
                              fontSize: tws.getInfoBoxTextSize(),
                              title: "name".tr(),
                              controller: nameController,
                              boxColor: const Color(0xffE0EAFF),
                              minWidth: 140,
                              hintText: "fillInName".tr(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: infoTextField(
                              title: "surname".tr(),
                              fontSize: tws.getInfoBoxTextSize(),
                              controller: surnameController,
                              boxColor: const Color(0xffE0EAFF),
                              minWidth: 140,
                              hintText: "fillInSurname".tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'role'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: DropdownButtonFormField<String>(
                          value: selectedRole.isNotEmpty ? selectedRole : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffE0EAFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            labelText:
                                selectedRole.isEmpty ? 'selectRole'.tr() : "",
                            labelStyle: TextStyle(
                              fontSize: tws.getInfoBoxTextSize(),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: "nurse",
                              child: Text(
                                "nurse".tr(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: tws.getInfoBoxTextSize(),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: "admin",
                              child: Text(
                                "admin".tr(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: tws.getInfoBoxTextSize(),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedRole =
                                  value ?? ''; // Set the selected role
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: infoTextField(
                        title: "nurseID".tr(),
                        fontSize: tws.getInfoBoxTextSize(),
                        controller: nurseIDController,
                        boxColor: const Color(0xffE0EAFF),
                        minWidth: 140,
                        hintText: "fillInNurseID".tr(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: submitData,
                        label: Text(
                          'save'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff407BFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Set border radius
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
