import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/func/calculate_mews.dart';
import 'package:tuh_mews/func/mews_input_validator.dart';
import 'package:tuh_mews/models/inspection_note.dart';
import 'package:tuh_mews/models/parameters.dart';
import 'package:tuh_mews/models/patient_id_name.dart';
import 'package:tuh_mews/provider/patient_id_name_provider.dart';
import 'package:tuh_mews/results/result_screens.dart';
import 'package:tuh_mews/services/mews_services.dart';
import 'package:tuh_mews/services/validate_service.dart';
import 'package:tuh_mews/utils/mews_form/model/mews_form_state.dart';
import 'package:tuh_mews/utils/mews_form/state/mews_form_provider.dart';

class InstantMEWsForm extends ConsumerStatefulWidget {
  final String? patientID;
  final String auditorID;
  final VoidCallback onPop;
  final bool showPatientSelector;

  const InstantMEWsForm({super.key, this.patientID, required this.auditorID, required this.onPop, this.showPatientSelector = false});

  @override
  // ignore: library_private_types_in_public_api
  _InstantMEWsFormState createState() => _InstantMEWsFormState();
}

class _InstantMEWsFormState extends ConsumerState<InstantMEWsForm> {
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController sysBloodPressureController = TextEditingController();
  final TextEditingController diaBloodPressureController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController respiratoryRateController = TextEditingController();
  final TextEditingController urineController = TextEditingController();
  final TextEditingController cvpController = TextEditingController();
  final FocusNode sysBpFocusNode = FocusNode();
  final FocusNode diasBpFocusNode = FocusNode();
  String consciousnessValue = "-";

  @override
  void initState() {
    super.initState();

    if (!widget.showPatientSelector && widget.patientID != null) {
      Future.microtask(() {
        ref.read(mewsFormProvider.notifier).setPatient(PatientIdName(id: widget.patientID!, name: ''));
      });
    }
  }

  @override
  void dispose() {
    heartRateController.dispose();
    temperatureController.dispose();
    sysBloodPressureController.dispose();
    diaBloodPressureController.dispose();
    spo2Controller.dispose();
    respiratoryRateController.dispose();
    urineController.dispose();
    super.dispose();
    sysBpFocusNode.dispose();
    diasBpFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mewsFormProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: _showMEWsForms(context, state),
    );
  }

  Widget _showMEWsForms(BuildContext context, MewsFormState state) {
    bool showPatientSelector = widget.showPatientSelector;
    bool enableButton = state.selectedPatient != null;
    final patientsAsync = ref.watch(patientListProvider);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,

      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: const Color(0xFFD7E0F5),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Center(child: Text(textAlign: TextAlign.center, "calculateMEWs".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5, bottom: 5), child: Text("consciousness".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                initialValue: consciousnessValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    consciousnessValue = newValue!;
                                  });
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                                items: [
                                  const DropdownMenuItem(value: "-", child: Padding(padding: EdgeInsets.only(left: 8), child: Text("-"))),
                                  DropdownMenuItem(value: "Conscious", child: Text("conscious".tr())),
                                  DropdownMenuItem(value: "Alert", child: Text("alert".tr())),
                                  DropdownMenuItem(value: "verbalStimuli", child: Text("verbalStimuli".tr())),
                                  DropdownMenuItem(value: "Pain", child: Text("pain".tr())),
                                  DropdownMenuItem(value: "Unresponsive", child: Text("unresponsive".tr())),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(top: 5, bottom: 5), child: Text("temperature".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                const Spacer(),
                                const Text("(°C)", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              height: 40, // Adjust height here
                              child: TextField(
                                controller: temperatureController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    // RegExp(r'^\d*\.?\d*$'), //! Many decimal place
                                    RegExp(r'^\d{0,3}(\.\d{0,1})?$'), //* 1 decimal place
                                  ), // Allows only numbers and one decimal point
                                ],
                                decoration: InputDecoration(
                                  hintText: '-',
                                  suffix: const Text('°C', style: TextStyle(fontWeight: FontWeight.bold)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusts height/padding
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                    borderSide: BorderSide.none, // Removes visible border line
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Row(
                                children: [
                                  Text("heartRate".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  const Text("(bpm)", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40, // Adjust height here
                              child: TextField(
                                controller: heartRateController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: "-",
                                  suffix: const Text("bpm", style: TextStyle(fontWeight: FontWeight.bold)),

                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16, // Adjusts height/padding
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text("respiratoryRate".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                const Text("(bpm)", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: respiratoryRateController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  suffix: const Text("bpm", style: TextStyle(fontWeight: FontWeight.bold)),
                                  hintText: '-',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusts height/padding
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                    borderSide: BorderSide.none, // Removes visible border line
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(top: 5), child: Text("bloodPressure".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                const Spacer(),
                                const Text("(mmHg)", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Padding(padding: EdgeInsets.only(bottom: 5), child: Text("Systolic", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          focusNode: sysBpFocusNode,
                                          onChanged: (value) {
                                            if (value.length == 3) {
                                              FocusScope.of(context).requestFocus(diasBpFocusNode);
                                            }
                                          },
                                          controller: sysBloodPressureController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: false),
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            hintText: '-',
                                            suffix: const Text("mmHg", style: TextStyle(fontWeight: FontWeight.bold)),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Padding(padding: EdgeInsets.only(bottom: 5), child: Text("Diastolic", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          focusNode: diasBpFocusNode,
                                          controller: diaBloodPressureController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: false),
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            hintText: '-',
                                            suffix: const Text("mmHg", style: TextStyle(fontWeight: FontWeight.bold)),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text("spO2 (${"whileGivingOxygen".tr()})", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                const Text("(%)", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                              child: TextField(
                                controller: spo2Controller,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: '-',
                                  suffix: const Text("%", style: TextStyle(fontWeight: FontWeight.bold)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusts height/padding
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                    borderSide: BorderSide.none, // Removes visible border line
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(top: 5, bottom: 5), child: Text("urine".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                const Spacer(),
                                const Text("(mL/hr)", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              height: 40, // Adjust height here
                              child: TextField(
                                controller: urineController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: '-',
                                  suffix: const Text("mL/hr", style: TextStyle(fontWeight: FontWeight.bold)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusts height/padding
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                    borderSide: BorderSide.none, // Removes visible border line
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            Row(children: [Padding(padding: const EdgeInsets.only(top: 5, bottom: 5), child: Text("CVP", style: const TextStyle(fontWeight: FontWeight.bold)))]),
                            SizedBox(
                              height: 40, // Adjust height here
                              child: TextField(
                                controller: cvpController,
                                decoration: InputDecoration(
                                  hintText: '-',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusts height/padding
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            if (showPatientSelector)
                              Padding(padding: const EdgeInsets.only(top: 5, bottom: 5), child: Text("selectPatient".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                            if (showPatientSelector)
                              SizedBox(
                                height: 40,
                                child: patientsAsync.when(
                                  data: (patients) {
                                    return DropdownSearch<PatientIdName>(
                                      items: (filter, _) async => patients,

                                      itemAsString: (PatientIdName p) => p.name,
                                      compareFn: (a, b) => a.id == b.id,

                                      selectedItem: state.selectedPatient,

                                      onSelected: (PatientIdName? value) {
                                        ref.read(mewsFormProvider.notifier).setPatient(value);
                                      },

                                      decoratorProps: DropDownDecoratorProps(
                                        decoration: InputDecoration(
                                          hintText: '-',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                        ),
                                      ),

                                      popupProps: const PopupProps.menu(showSelectedItems: true, showSearchBox: true),
                                    );
                                  },

                                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),

                                  error: (err, stack) => SizedBox(height: 40, child: Center(child: Text('Error loading patients'))),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              // Use a separate variable
                              return AlertDialog(
                                title: Text("confirmAction".tr()),
                                content: Text("proceed?".tr()),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false); // User pressed cancel
                                    },
                                    child: Text("cancel".tr()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true); // User confirmed
                                    },
                                    child: Text("confirm".tr()),
                                  ),
                                ],
                              );
                            },
                          ).then((confirmed) {
                            if (mounted && confirmed == true) {
                              setState(() {
                                // Ensure UI updates properly
                                heartRateController.text = "";
                                temperatureController.text = "";
                                sysBloodPressureController.text = "";
                                diaBloodPressureController.text = "";
                                spo2Controller.text = "";
                                respiratoryRateController.text = "";
                                urineController.text = "";
                                cvpController.text = "";
                                consciousnessValue = "-";

                                ref.read(mewsFormProvider.notifier).setPatient(null);
                              });
                            }
                          });
                        },
                        child: Text(
                          'reset'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, decoration: TextDecoration.underline, decorationColor: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: enableButton ? const Color(0xFF3362CC) : Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed:
                            enableButton
                                ? () async {
                                  createNoteAndMews(showPatientSelector);
                                }
                                : () {},
                        child: Text('calculate'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: IconButton(
              icon: const Icon(
                Icons.close, // Close icon
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void createNoteAndMews(bool showPatientSelector) async {
    DateTime now = DateTime.now();

    // Add new Note in Database collection
    String patientId = '';
    if (showPatientSelector) {
      PatientIdName? pin = ref.read(mewsFormProvider).selectedPatient;
      if (pin == null) return;
      patientId = pin.id;
    } else {
      if (widget.patientID == null) {
        return;
      }
      patientId = widget.patientID ?? '';
    }

    InspectionNote newInspection = InspectionNote(patientID: patientId, auditorID: widget.auditorID, time: now);
    String inspectionNotesID = '';

    try {
      // Get NoteID from response
      Map<int, String> status = await MEWsService().addNewInspection(inspectionNote: newInspection);
      ValidateService(context: context, status: status, showSuccessFlushbar: false).validate();
      String response = status.values.first;

      Map<String, dynamic> decoded = jsonDecode(response);
      inspectionNotesID = decoded['inspection_notes_id'];
    } catch (e) {
      return;
    }

    String hr = heartRateController.text.trim();
    String temp = temperatureController.text.trim();
    String sBp = sysBloodPressureController.text.trim();
    String dBp = diaBloodPressureController.text.trim();
    String spO2 = spo2Controller.text.trim();
    String rr = respiratoryRateController.text.trim();
    String urine = urineController.text.trim();
    String conscious = consciousnessValue;
    String cvp = cvpController.text.trim();

    bool proceed = await MewsInputValidator().validateInput(ctx: context, temp: temp, heartRate: hr);

    if (!proceed) {
      return;
    }

    hr = (hr == ' ') ? '-' : hr;
    temp = (temp == ' ') ? '-' : temp;
    sBp = (sBp == ' ') ? '-' : sBp;
    dBp = (dBp == ' ') ? '-' : dBp;
    spO2 = (spO2 == ' ') ? '-' : spO2;
    rr = (rr == ' ') ? '-' : rr;
    urine = (urine == ' ') ? '-' : urine;
    cvp = (cvp == ' ') ? '-' : cvp;

    int MEWs = calculateMEWs(
      consciousness: conscious,
      heartRate: (hr != '-') ? int.tryParse(hr) : null,
      temperature: (temp != '-') ? double.tryParse(temp) : null,
      respiratoryRate: (rr != '-') ? int.tryParse(rr) : null,
      systolicBp: (sBp != '-') ? int.tryParse(sBp) : null,
      spo2: (spO2 != '-') ? int.tryParse(spO2) : null,
      urine: (urine != '-') ? int.tryParse(urine) : null,
    );

    Parameters parameters = Parameters(
      patientId: widget.patientID ?? '',
      consciousness: conscious,
      heartRate: hr,
      urine: urine,
      spo2: spO2,
      temperature: temp,
      respiratoryRate: rr,
      bloodPressure: '$sBp/$dBp',
      mews: MEWs.toString(),
      cvp: cvp,
      isAssessed: true,
      assessTime: DateTime.now(),
    );

    Map<int, String> state = await MEWsService().addMEWs(inspectionNotesID, parameters);
    final navigator = Navigator.of(context);
    if (state.containsKey(200)) {
      if (mounted) {
        Navigator.pop(context);
        showResultDialog(MEWs: MEWs, noteID: inspectionNotesID, onPop: widget.onPop, navigator: navigator);
      }

      widget.onPop();
    } else {
      return;
    }
  }
}
