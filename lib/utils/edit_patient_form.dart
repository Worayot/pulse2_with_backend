import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/services/logout_service.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/utils/flushbar.dart';
import 'package:tuh_mews/utils/gender_dropdown.dart';
import 'package:tuh_mews/utils/info_text_field.dart';
import 'package:tuh_mews/utils/warning_dialog.dart';

// import 'package:pulse/services/'

class EditPatientForm extends StatefulWidget {
  final String patientId;
  final String name;
  final String surname;
  final String age;
  final String gender;
  final String hn;
  final String bedNum;
  final String ward;
  const EditPatientForm({
    super.key,
    required this.patientId,
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
    required this.hn,
    required this.bedNum,
    required this.ward,
  });

  @override
  State<EditPatientForm> createState() => _EditPatientFormState();
}

class _EditPatientFormState extends State<EditPatientForm> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController ageController;
  late TextEditingController wardController;
  late TextEditingController hnController;
  late TextEditingController bedNumController;

  bool enableSaveButton = true;
  bool enableDeleteButton = true;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    surnameController = TextEditingController(text: widget.surname);
    ageController = TextEditingController(text: widget.age);
    wardController = TextEditingController(text: widget.ward);
    hnController = TextEditingController(text: widget.hn);
    bedNumController = TextEditingController(text: widget.bedNum);

    _selectedGender = widget.gender; // Initialize gender dropdown
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    ageController.dispose();
    wardController.dispose();
    hnController.dispose();
    bedNumController.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    setState(() {
      enableSaveButton = false;
    });
    String age = ageController.text.trim();

    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String ward = wardController.text.trim();
    String hn = hnController.text.trim();
    String bedNum = bedNumController.text.trim();

    if (age.isNotEmpty && (int.parse(age) > 120 || int.parse(age) < 1)) {
      return;
    }

    if (name.isEmpty ||
        surname.isEmpty ||
        age.isEmpty ||
        ward.isEmpty ||
        hn.isEmpty ||
        bedNum.isEmpty ||
        _selectedGender == null ||
        _selectedGender == "-") {
      setState(() {
        enableSaveButton = true;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning".tr()),
            content: Text("plsFillInAllTheFields".tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("ok".tr()),
              ),
            ],
          );
        },
      );
      return;
    } else {
      PatientService patientService = PatientService();
      Patient patient = Patient(
        patientId: widget.patientId,
        fullname: '$name $surname',
        age: age,
        gender: _selectedGender ?? 'N/A',
        bedNumber: bedNum,
        ward: ward,
        hospitalNumber: hn,
      );

      // Call the updatePatient function and await its result
      Map<int, String> updateStatus = await patientService.updatePatient(
        widget.patientId,
        patient,
      );

      int updateStatusCode = updateStatus.keys.first;

      // Check if the update was successful before popping the navigator
      if (updateStatusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          FlushbarService().showSuccessMessage(
            context: context,
            title: 'success'.tr(),
            message: "successfullyUpdatedPatientData".tr(),
            duration: 2,
          );
        } else if (updateStatusCode == 401) {
          if (mounted) {
            LogoutService(navigator: Navigator.of(context)).logout();
            FlushbarService().showErrorMessage(
              context: context,
              message: '$updateStatusCode ${updateStatus.values.first}',
            );
          }
        } else {
          setState(() {
            enableSaveButton = true;
          });
          if (mounted) {
            FlushbarService().showErrorMessage(
              context: context,
              message: "failedToUpdatePatientData".tr(),
            );
          }
        }
      } else {
        setState(() {
          enableSaveButton = true;
        });
        if (mounted) {
          FlushbarService().showErrorMessage(
            context: context,
            message: "failedToUpdatePatientData".tr(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextWidgetSize tws = TextWidgetSize(context: context);
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 475,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                child: Row(
                  children: [
                    Text(
                      "editPatientData".tr(),
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
                              title: "name".tr(),
                              fontSize: tws.getInfoBoxTextSize(),
                              controller: nameController,
                              boxColor: const Color(0xffE0EAFF),
                              minWidth: 140,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: infoTextField(
                            title: "age".tr(),
                            fontSize: tws.getInfoBoxTextSize(),
                            controller: ageController,
                            boxColor: const Color(0xffE0EAFF),
                            minWidth: 140,
                            numberOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              final number = int.tryParse(value);
                              if (number == null ||
                                  number < 1 ||
                                  number > 120) {
                                return '1-120';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 8),
                            child: GenderDropdown(
                              selectedGender: _selectedGender,
                              fillSpace: false,
                              onGenderChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: infoTextField(
                              title: "hnNo".tr(),
                              fontSize: tws.getInfoBoxTextSize(),
                              controller: hnController,
                              boxColor: const Color(0xffE0EAFF),
                              minWidth: 140,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: infoTextField(
                              title: "bedNumber".tr(),
                              fontSize: tws.getInfoBoxTextSize(),
                              controller: bedNumController,
                              boxColor: const Color(0xffE0EAFF),
                              minWidth: 140,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: infoTextField(
                        title: "ward".tr(),
                        fontSize: tws.getInfoBoxTextSize(),
                        controller: wardController,
                        boxColor: const Color(0xffE0EAFF),
                        minWidth: 140,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder<String?>(
                          future: loadStringPreference('role'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error loading role: ${snapshot.error}',
                              );
                            } else if (snapshot.data == "admin") {
                              return TextButton(
                                onPressed:
                                    enableDeleteButton
                                        ? () async {
                                          bool result = await showWarningDialog(
                                            context,
                                          ); // Wait for user choice
                                          if (result) {
                                            setState(() {
                                              enableDeleteButton = false;
                                            });
                                            PatientService patientService =
                                                PatientService();
                                            Map<int, String> deleteStatus =
                                                await patientService
                                                    .deletePatient(
                                                      widget.patientId,
                                                    );

                                            int deleteStatusCode =
                                                deleteStatus.keys.first;
                                            String deleteStatusMessage =
                                                '$deleteStatusCode ${deleteStatus.values.first}';

                                            if ((deleteStatusCode == 200) &&
                                                mounted) {
                                              Navigator.pop(context);
                                              FlushbarService().showSuccessMessage(
                                                context: context,
                                                message:
                                                    "${"successfullyDeletedPatientData".tr()}\n ${widget.name} ${widget.surname}",
                                              );
                                            } else if (deleteStatusCode ==
                                                401) {
                                              LogoutService(
                                                navigator: Navigator.of(
                                                  context,
                                                ),
                                              ).logout();
                                              FlushbarService()
                                                  .showErrorMessage(
                                                    context: context,
                                                    message:
                                                        deleteStatusMessage,
                                                  );
                                            } else {
                                              if (mounted) {
                                                FlushbarService().showErrorMessage(
                                                  context: context,
                                                  message:
                                                      "failedToDeletePatientData"
                                                          .tr(),
                                                );
                                                setState(() {
                                                  enableDeleteButton = true;
                                                });
                                              }
                                            }
                                          } else {
                                            // User cancelled or dismissed the dialog
                                            setState(() {
                                              enableDeleteButton = true;
                                            });
                                          }
                                        }
                                        : () {},
                                child: Text(
                                  'deletePatient'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                              );
                            }
                            return Container(); // If not admin, don't show this tile
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: enableSaveButton ? submitData : () {},
                            label:
                                enableSaveButton
                                    ? Text(
                                      'save'.tr(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: CircularProgressIndicator(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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
