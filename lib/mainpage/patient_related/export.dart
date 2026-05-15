import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuh_mews/func/filter_patient.dart';
import 'package:tuh_mews/models/patient.dart';
import 'package:tuh_mews/models/patient_filter_state.dart';
import 'package:tuh_mews/services/export_services.dart';
import 'package:tuh_mews/services/validate_service.dart';
import 'package:tuh_mews/utils/flushbar.dart';
import 'package:tuh_mews/utils/patient_card_export.dart';
import 'package:tuh_mews/utils/warning_dialog.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController hnController = TextEditingController();
  final TextEditingController bedController = TextEditingController();

  bool enableButton = true;
  bool isDownloadCanceled = false;

  List<Patient> _patients = [];
  final List<Patient> _filteredPatients = [];
  String _fullnameFilter = '';

  List<Patient> _applyFilters(List<Patient> patients, PatientFilterState filter) {
    return patients.where((patient) {
      final nameParts = patient.fullname.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
      final lastName = nameParts.length > 1 ? nameParts[1] : "";

      final matchesName = filter.name.isEmpty || firstName.toLowerCase().contains(filter.name.toLowerCase());

      final matchesSurname = filter.surname.isEmpty || lastName.toLowerCase().contains(filter.surname.toLowerCase());

      final matchesWard = filter.ward.isEmpty || patient.ward.toLowerCase().contains(filter.ward.toLowerCase());

      final matchesHN = filter.hn.isEmpty || patient.hospitalNumber.toLowerCase().contains(filter.hn.toLowerCase());

      final matchesBed = filter.bedNumber.isEmpty || patient.bedNumber.toLowerCase().contains(filter.bedNumber.toLowerCase());

      final matchesGender =
          (filter.male == filter.female) || (filter.male && patient.gender.toLowerCase() == "male") || (filter.female && patient.gender.toLowerCase() == "female");

      final age = int.tryParse(patient.age) ?? 0;

      final matchesAge = age >= filter.ageRange.start && age <= filter.ageRange.end;

      return matchesName && matchesSurname && matchesWard && matchesHN && matchesBed && matchesGender && matchesAge;
    }).toList();
  }

  void cancelDownload() {
    debugPrint("User dismissed");
    setState(() {
      isDownloadCanceled = true;
      enableButton = true;
    });
  }

  @override
  void initState() {
    super.initState();

    EasyLoading.instance
      ..dismissOnTap = true
      ..userInteractions = true;
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        cancelDownload();
      }
    });

    FirebaseFirestore.instance.collection('patients').snapshots().listen((snapshot) {
      final patients =
          snapshot.docs.map((doc) {
            var patientData = doc.data();
            var docId = doc.id;

            return Patient(
              age: patientData['age'],
              bedNumber: patientData['bed_number'],
              fullname: patientData['fullname'],
              gender: patientData['gender'],
              ward: patientData['ward'],
              hospitalNumber: patientData['hospital_number'],
              patientId: docId,
            );
          }).toList();

      patients.sort((a, b) => a.fullname.compareTo(b.fullname));

      setState(() {
        _patients = patients;
        resetPatientFilter(ref: ref); // reset filter
        _filterPatients(); // apply immediately
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    nameController.dispose();
    surnameController.dispose();
    wardController.dispose();
    hnController.dispose();
    bedController.dispose();

    EasyLoading.removeAllCallbacks();
    EasyLoading.instance
      ..dismissOnTap = false
      ..userInteractions = false;

    super.dispose();
  }

  void _filterPatients() {
    final filter = ref.read(patientFilterProvider);

    setState(() {
      final baseFiltered = _applyFilters(_patients, filter);

      _filteredPatients.clear();
      _filteredPatients.addAll(
        baseFiltered.where((patient) {
          return _fullnameFilter.isEmpty || patient.fullname.toLowerCase().contains(_fullnameFilter.toLowerCase());
        }),
      );
    });
  }

  Widget buildPatientCards() {
    // Build the ListView for the patient list
    return ListView.builder(
      // separatorBuilder: (context, index) => const Gap(8),
      padding: EdgeInsets.zero,
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return PatientCardExport(patient: patient);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PatientFilterState>(patientFilterProvider, (previous, next) {
      _filterPatients();
    });
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              const Gap(28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(alignment: Alignment.topLeft, child: Text("exportData".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
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

                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),

                          prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.black),
                          suffixIcon:
                              _fullnameFilter.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.black),
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
                          fillColor: const Color(0xffCADBFF), // Sets the background color
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        showFilterDialog(
                          context: context,
                          ref: ref,
                          nameController: nameController,
                          surnameController: surnameController,
                          wardController: wardController,
                          hnController: hnController,
                          bedController: bedController,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 55,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xff407BFF)),
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.filter, color: Color(0xffCADBFF)),
                            const SizedBox(width: 5),
                            Text('filterData'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: buildPatientCards())),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        resetPatientFilter(ref: ref);
                      },
                      child: Text(
                        'resetFilters'.tr(),
                        style: TextStyle(
                          color: Colors.red, // Set text color to red
                          decoration: TextDecoration.underline, // Add underline
                          decorationColor: Colors.red, // Set underline color to red
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.035),
                    Builder(
                      builder: (buttonContext) {
                        return GestureDetector(
                          onTap:
                              enableButton & _filteredPatients.isNotEmpty
                                  ? () async {
                                    FocusScope.of(context).unfocus();

                                    setState(() {
                                      enableButton = false;
                                    });
                                    try {
                                      bool result = await showWarningDialog(context);
                                      if (result && mounted) {
                                        await _exportAll(buttonContext);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        FlushbarService.showErrorMessage(context: context, message: 'An unexpected error occurred: $e');
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            height: 40,
                            decoration: BoxDecoration(color: _filteredPatients.isNotEmpty ? const Color(0xff407BFF) : Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                '${'downloadAllDisplayed'.tr()} (${_filteredPatients.length})',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        );
                      },
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

  Future<void> _exportAll(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;

    setState(() {
      isDownloadCanceled = false;
      enableButton = false;
    });

    EasyLoading.show(status: 'Downloading...');

    final exportService = ExportServices();
    List<String> patientIds = _filteredPatients.map((patient) => patient.patientId ?? '').toList();

    Map<int, String> result = await exportService.export(patientIds, onCheckCancel: () => isDownloadCanceled);

    if (isDownloadCanceled) {
      debugPrint("Stopping: User already canceled.");
      return;
    }

    EasyLoading.removeAllCallbacks();
    EasyLoading.dismiss();

    if (result.containsKey(200)) {
      final filePath = result[200]!;
      final file = XFile(filePath);

      if (!isDownloadCanceled && mounted) {
        debugPrint("Opening Share Sheet...");
        await SharePlus.instance.share(ShareParams(files: [file], sharePositionOrigin: box != null ? (box.localToGlobal(Offset.zero) & box.size) : null));
      }
    } else {
      if (!isDownloadCanceled) {
        ValidateService(status: result, context: context).validate();
      }
    }

    _setupEasyLoadingCallback();
  }

  void _setupEasyLoadingCallback() {
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        cancelDownload();
      }
    });
  }
}
