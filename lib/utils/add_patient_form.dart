import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/services/patient_services.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';
import 'package:tuh_mews/utils/gender_dropdown.dart';
import 'package:tuh_mews/utils/info_text_field.dart';
import '../models/patient.dart';

class AddPatientForm extends StatefulWidget {
  const AddPatientForm({super.key});

  @override
  State<AddPatientForm> createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController hnController = TextEditingController();
  final TextEditingController bedNumController = TextEditingController();

  String? _selectedGender;
  final PatientService _patientService = PatientService();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false; // Flag to prevent multiple submissions

  Future<void> _submitForm() async {
    if (_isSubmitting) {
      // If already submitting, do nothing
      return;
    }

    setState(() {
      _isSubmitting = true; // Set submitting flag to true
    });

    if (_formKey.currentState!.validate()) {
      String fullname = '${nameController.text} ${surnameController.text}';
      Patient patient = Patient(
        fullname: fullname,
        age: ageController.text,
        gender: _selectedGender ?? '-',
        ward: wardController.text,
        bedNumber: bedNumController.text,
        hospitalNumber: hnController.text,
      );

      bool success = await _patientService.addPatient(patient);

      if (mounted) {
        if (success) {
          Navigator.pop(context); // Pop the form if successful
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add patient.")),
          );
        }
        setState(() {
          _isSubmitting =
              false; // Set submitting flag back to false after process is complete
        });
      }
    }
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

  void submitData() {
    String name = nameController.text.trim();
    String surname = surnameController.text.trim();
    String age = ageController.text.trim();
    String ward = wardController.text.trim();
    String hn = hnController.text.trim();
    String bedNum = bedNumController.text.trim();

    if (name.isEmpty ||
        surname.isEmpty ||
        age.isEmpty ||
        ward.isEmpty ||
        hn.isEmpty ||
        bedNum.isEmpty ||
        _selectedGender == null) {
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
      return;
    } else {
      _submitForm(); // Proceed with submission if no empty fields
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
          height: 475,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                child: Row(
                  children: [
                    Text(
                      "addPatientData".tr(),
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

              Form(
                key: _formKey,
                child: Padding(
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
                                  _isSubmitting = false;
                                  return null;
                                }
                                final number = int.tryParse(value);
                                if (number == null ||
                                    number < 1 ||
                                    number > 120) {
                                  _isSubmitting = false;
                                  return '1-120';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4.0,
                                right: 8,
                              ),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : submitData, // Disable if submitting
                          label:
                              _isSubmitting
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'save'.tr(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isSubmitting
                                    ? const Color(0xffE0EAFF)
                                    : const Color(0xff407BFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
