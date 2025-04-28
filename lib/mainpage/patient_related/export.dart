import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/services/export_services.dart';
import 'package:tuh_mews/services/logout_service.dart';
import 'package:tuh_mews/services/validate_service.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';
import 'package:tuh_mews/func/pref/pref.dart';
import 'package:tuh_mews/utils/flushbar.dart';
import 'package:tuh_mews/utils/info_text_field_filter.dart';
import 'package:tuh_mews/utils/patient_card_export.dart';
import 'package:tuh_mews/utils/toggle_button.dart';
import 'package:tuh_mews/utils/warning_dialog.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _hnController = TextEditingController();
  final TextEditingController _bedNumController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _maleToggle = false;
  bool _femaleToggle = false;
  bool enableButton = true;

  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  late StreamSubscription<QuerySnapshot> _streamSubscription;

  String _fullnameFilter = '';
  double _minAge = 0;
  double _maxAge = 120;

  @override
  void initState() {
    super.initState();
    _streamSubscription = FirebaseFirestore.instance
        .collection('patients')
        .snapshots()
        .listen((snapshot) {
          final patients =
              snapshot.docs.map((doc) {
                var patientData = doc.data();
                var docId = doc.id;

                Patient patient = Patient(
                  age: patientData['age'],
                  bedNumber: patientData['bed_number'],
                  fullname: patientData['fullname'],
                  gender: patientData['gender'],
                  ward: patientData['ward'],
                  hospitalNumber: patientData['hospital_number'],
                  patientId: docId,
                );
                return patient;
              }).toList();

          patients.sort((a, b) => a.fullname.compareTo(b.fullname));

          // Update patients list and filter
          setState(() {
            _patients = patients;
            _filterPatients();
            _resetFilters();
          });
        });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _wardController.dispose();
    _hnController.dispose();
    _bedNumController.dispose();
    super.dispose();
  }

  void _filterPatients() {
    setState(() {
      _filteredPatients =
          _patients.where((patient) {
            // Extract patient names safely
            final nameParts = patient.fullname.split(" ");
            final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
            final lastName = nameParts.length > 1 ? nameParts[1] : "";

            // Apply name and other filters
            final matchesFullname =
                _fullnameFilter.isEmpty ||
                patient.fullname.trim().toLowerCase().contains(
                  _fullnameFilter.toLowerCase().trim(),
                );
            final matchesName =
                _nameController.text.isEmpty ||
                firstName.toLowerCase().trim().contains(
                  _nameController.text.toLowerCase().trim(),
                );
            final matchesSurname =
                _surnameController.text.isEmpty ||
                lastName.toLowerCase().trim().contains(
                  _surnameController.text.toLowerCase().trim(),
                );
            final matchesWard =
                _wardController.text.isEmpty ||
                patient.ward.toLowerCase().trim().contains(
                  _wardController.text.toLowerCase().trim(),
                );

            // Gender filter logic
            final matchesGender =
                (_maleToggle == _femaleToggle) ||
                (_maleToggle &&
                    patient.gender.toLowerCase().trim() == "male") ||
                (_femaleToggle &&
                    patient.gender.toLowerCase().trim() == "female");

            // Other filters
            final matchesHospitalNumber =
                _hnController.text.isEmpty ||
                patient.hospitalNumber.toLowerCase().trim().contains(
                  _hnController.text.toLowerCase().trim(),
                );
            final matchesBedNumber =
                _bedNumController.text.isEmpty ||
                patient.bedNumber.toLowerCase().trim().contains(
                  _bedNumController.text.toLowerCase().trim(),
                );
            final matchesAge =
                (int.tryParse(patient.age)! >= _minAge) &&
                (int.tryParse(patient.age)! <= _maxAge);

            // Combine all conditions
            return matchesName &&
                matchesSurname &&
                matchesWard &&
                matchesGender &&
                matchesHospitalNumber &&
                matchesBedNumber &&
                matchesAge &&
                matchesFullname;
          }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _fullnameFilter = '';
      _nameController.text = '';
      _surnameController.text = '';
      _wardController.text = '';
      _maleToggle = false;
      _femaleToggle = false;
      _hnController.text = '';
      _bedNumController.text = '';
      _minAge = 0;
      _maxAge = 120;
      _filteredPatients = _patients;
    });
    savePreference("male_toggle_state", false);
    savePreference("female_toggle_state", false);
  }

  void showFilterDialog(context) {
    // TextWidgetSize tws = TextWidgetSize(context: context);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xffF5F5F5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics:
                    const ClampingScrollPhysics(), // Prevent unnecessary scrolling
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: SizedBox(
                    width: 400,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 5,
                          right: 5,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ClipRect(
                            child: SizedBox(
                              height: 280,
                              child: Opacity(
                                opacity: 1,
                                child: Image.asset(
                                  'assets/images/filter.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'filterPatients'.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              _buildFilterInputs(),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return _buildAgeSlider(setState);
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _filterPatients();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff407BFF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'filterData'.tr(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterInputs() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: infoTextField(
                title: "name".tr(),
                controller: _nameController,
                boxColor: const Color(0xffE0EAFF),
                context: context,
                fillSpace: true,
                hintText: "-",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: infoTextField(
                title: "surname".tr(),
                controller: _surnameController,
                boxColor: const Color(0xffE0EAFF),
                context: context,
                fillSpace: true,
                hintText: "-",
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "gender".tr(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: ToggleButton(
                      text: "male".tr(),
                      icon: Icons.male,
                      activeColor: const Color(0xff5C9FEE),
                      inactiveColor: const Color(0xffE0EAFF),
                      onToggle: (value) {
                        _maleToggle = value;
                      },
                      preferenceKey:
                          "male_toggle_state", // Unique key for male toggle
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ToggleButton(
                      text: "female".tr(),
                      icon: Icons.female,
                      activeColor: const Color(0xffD63A67),
                      inactiveColor: const Color(0xffF9AEC3),
                      onToggle: (value) {
                        _femaleToggle = value;
                      },
                      preferenceKey:
                          "female_toggle_state", // Unique key for female toggle
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: infoTextField(
                title: "hn".tr(),
                controller: _hnController,
                boxColor: const Color(0xffE0EAFF),
                context: context,
                fillSpace: true,
                hintText: "-",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: infoTextField(
                title: "bedNumber".tr(),
                controller: _bedNumController,
                boxColor: const Color(0xffE0EAFF),
                context: context,
                fillSpace: true,
                hintText: "-",
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: infoTextField(
            title: "ward".tr(),
            controller: _wardController,
            boxColor: const Color(0xffE0EAFF),
            context: context,
            fillSpace: true,
            hintText: "-",
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "age".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSlider(StateSetter setState) {
    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
            activeTrackColor: Color(0xff4672D6), // Color of the active track
            inactiveTrackColor: Colors.grey, // Color of the inactive track
            thumbColor: Color(0xff5677C3), // Color of the thumb circle
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 16,
            ), // Thumb size (radius)
            overlayColor:
                Colors
                    .transparent, // Color of the overlay when the thumb is pressed
            trackHeight: 6, // Height of the track
            rangeTrackShape: RectangularRangeSliderTrackShape(),
            valueIndicatorColor: Color(0xff407BFF),
          ),
          child: RangeSlider(
            values: RangeValues(_minAge, _maxAge),
            min: 0,
            max: 120,
            divisions: 120,
            labels: RangeLabels(
              '${_minAge.toInt()} ${"yrs".tr()}',
              '${_maxAge.toInt()} ${"yrs".tr()}',
            ),
            activeColor: const Color(0xff4672D6),
            inactiveColor: const Color(
              0xffE0EAFF,
            ), // Set the inactive color (track)
            onChanged: (values) {
              setState(() {
                _minAge = values.start;
                _maxAge = values.end;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildPatientCards() {
    // Build the ListView for the patient list
    return ListView.builder(
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return PatientCardExport(patient: patient);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // SearchBarSetting sbs = SearchBarSetting(context: context);
    // ButtonNextToSearchBarSetting btnsb = ButtonNextToSearchBarSetting(
    //   context: context,
    // );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "exportData".tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: getPageTitleSize(context),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    // height: sbs.getHeight(),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _fullnameFilter = value;
                          _filterPatients();
                        });
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "${"search".tr()}...",

                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none,
                        ),

                        prefixIcon: const Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: Colors.black,
                        ),
                        suffixIcon:
                            _fullnameFilter.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _fullnameFilter = '';
                                      _filterPatients();
                                    });
                                  },
                                )
                                : null,
                        filled: true, // Enables the background color
                        fillColor: const Color(
                          0xffCADBFF,
                        ), // Sets the background color
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  // height: sbs.getHeight(),
                  child: ElevatedButton(
                    onPressed: () {
                      showFilterDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 10,
                      ),
                      backgroundColor: const Color(0xff407BFF),
                      // fixedSize: Size.fromHeight(sbs.getHeight()),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.filter,
                          color: Color(0xffCADBFF),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'filterData'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: buildPatientCards()),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: _resetFilters,
                  child: Text(
                    'resetFilters'.tr(),
                    style: TextStyle(
                      color: Colors.red, // Set text color to red
                      decoration: TextDecoration.underline, // Add underline
                      decorationColor: Colors.red, // Set underline color to red
                      fontWeight: FontWeight.bold,
                      // fontSize: size.width * 0.035,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.035),
                ElevatedButton.icon(
                  onPressed:
                      enableButton
                          ? () async {
                            setState(() {
                              enableButton = false;
                            });
                            try {
                              bool result = await showWarningDialog(
                                context,
                              ); // Wait for user choice
                              final navigator = Navigator.of(context);
                              if (result && mounted) {
                                // bool status = await _exportAll();
                                Map<int, String> status = await _exportAll();
                                ValidateService(
                                  status: status,
                                  navigator: navigator,
                                ).validate();
                              }
                            } catch (e) {
                              if (mounted) {
                                FlushbarService().showErrorMessage(
                                  context: context,
                                  message: 'An unexpected error occurred: $e',
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  enableButton = true;
                                });
                              }
                            }
                          }
                          : () {},
                  label:
                      enableButton
                          ? Text(
                            '${'downloadAllDisplayed'.tr()} (${_filteredPatients.length})',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              // fontSize: size.width * 0.035,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )
                          : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(
                      0xff407BFF,
                    ), // Set background color to blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Set border radius
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<int, String>> _exportAll() async {
    final exportServices = ExportServices();
    List<String> patientIds =
        _filteredPatients.map((patient) => patient.patientId ?? '').toList();

    Map<int, String> status = await exportServices.export(patientIds);
    return status;
  }
}
