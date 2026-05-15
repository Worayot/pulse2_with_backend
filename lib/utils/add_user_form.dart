import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tuh_mews/models/user.dart';
import 'package:tuh_mews/services/logout_service.dart';
import 'package:tuh_mews/services/user_services.dart';
import 'package:tuh_mews/utils/flushbar.dart';
import 'package:tuh_mews/utils/info_text_field.dart';
import 'package:tuh_mews/utils/password_validation_widget.dart';

class AddUserForm extends StatefulWidget {
  const AddUserForm({super.key});

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nurseIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = '';
  String password = '';
  bool _isSubmitting = false;
  bool _isEditingPassword = false;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          _isEditingPassword = true;
        });
      } else {
        setState(() {
          _isEditingPassword = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    nurseIDController.dispose();
    passwordController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void submitData() async {
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
    String newPassword = passwordController.text.trim();

    if (name.isEmpty || surname.isEmpty || selectedRole.isEmpty || nurseID.isEmpty || newPassword.isEmpty) {
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
      if (PasswordValidator.isValid(newPassword) == false) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Uncomment the following line when you want to add user data
      Map<int, String> status = await UserServices().addUser(User(fullname: '$name $surname', nurseId: nurseID, password: password, role: selectedRole));

      int statusCode = status.keys.first;
      String message = '$statusCode ${status.values.first}';

      // Set _isSubmitting back to false after submission completes
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      if (statusCode == 200) {
        if (mounted) {
          Navigator.pop(context); // Pop the current form
        }
      } else if (statusCode == 401) {
        if (mounted) {
          FlushbarService.showErrorMessage(context: context, message: message);
          LogoutService(navigator: Navigator.of(context));
        }
      } else {
        if (mounted) {
          FlushbarService.showErrorMessage(context: context, message: message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
              child: Row(
                children: [
                  Text("addUserData".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 30),
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
                          child: InfoTextField(
                            fontSize: 14,
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
                          child: InfoTextField(
                            title: "surname".tr(),
                            fontSize: 14,
                            controller: surnameController,
                            boxColor: const Color(0xffE0EAFF),
                            minWidth: 140,
                            hintText: "fillInSurname".tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.only(left: 8.0), child: Row(children: [Text('role'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))])),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedRole.isNotEmpty ? selectedRole : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffE0EAFF),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          hintText: selectedRole.isEmpty ? 'selectRole'.tr() : "",
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                        items: [
                          DropdownMenuItem(value: "nurse", child: Text("nurse".tr(), style: TextStyle(color: Colors.black, fontSize: 14))),
                          DropdownMenuItem(value: "admin", child: Text("admin".tr(), style: TextStyle(color: Colors.black, fontSize: 14))),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedRole = value ?? '';
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: InfoTextField(
                      title: "nurseID".tr(),
                      fontSize: 14,
                      controller: nurseIDController,
                      boxColor: const Color(0xffE0EAFF),
                      minWidth: 140,
                      hintText: "fillInNurseID".tr(),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: InfoTextField(
                      title: "password".tr(),
                      fontSize: 14,
                      controller: passwordController,
                      focusNode: focusNode,
                      boxColor: const Color(0xffE0EAFF),
                      minWidth: 140,
                      hintText: "fillInPassword".tr(),
                      obscure: true,
                      showToggle: true,
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (_isEditingPassword && password.trim().isNotEmpty) ? 1 : 0,
                      child: (_isEditingPassword && password.trim().isNotEmpty) ? PasswordValidationWidget(password: password) : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: submitData,
                      label:
                          !_isSubmitting
                              ? Text('save'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
                              : CircularProgressIndicator(color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff407BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Set border radius
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
    );
  }
}
