import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/models/patient_filter_state.dart';
import 'package:tuh_mews/utils/info_text_field_filter.dart';
import 'package:tuh_mews/utils/toggle_button.dart';

final patientFilterProvider = StateProvider<PatientFilterState>((ref) => PatientFilterState());

void resetPatientFilter({
  required WidgetRef ref,
  TextEditingController? nameController,
  TextEditingController? surnameController,
  TextEditingController? wardController,
  TextEditingController? hnController,
  TextEditingController? bedController,
}) {
  ref.read(patientFilterProvider.notifier).state = PatientFilterState();

  nameController?.clear();
  surnameController?.clear();
  wardController?.clear();
  hnController?.clear();
  bedController?.clear();
}

void showFilterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required TextEditingController nameController,
  required TextEditingController surnameController,
  required TextEditingController wardController,
  required TextEditingController hnController,
  required TextEditingController bedController,
}) {
  ref.read(patientFilterProvider);

  showDialog(
    context: context,
    builder: (context) {
      final notifier = ref.read(patientFilterProvider.notifier);

      return Consumer(
        builder: (context, ref, _) {
          final filter = ref.watch(patientFilterProvider);
          return Dialog(
            backgroundColor: const Color(0xffF5F5F5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                    child: SizedBox(
                      width: 400,
                      child: Stack(
                        children: [
                          /// CLOSE BUTTON
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(icon: const Icon(Icons.close, color: Colors.black, size: 30), onPressed: () => Navigator.of(context).pop()),
                          ),

                          /// BACKGROUND IMAGE
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ClipRect(child: SizedBox(height: 280, child: Opacity(opacity: 1, child: Image.asset('assets/images/filter.png', fit: BoxFit.contain)))),
                          ),

                          /// CONTENT
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(fit: BoxFit.scaleDown, child: Text('filterPatients'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                ),

                                const SizedBox(height: 16),

                                /// NAME
                                InfoTextField(
                                  title: "name".tr(),
                                  controller: nameController,
                                  boxColor: const Color(0xffE0EAFF),

                                  fillSpace: true,
                                  hintText: "-",
                                  onChanged: (val) {
                                    notifier.state = ref.read(patientFilterProvider).copyWith(name: val);
                                  },
                                ),

                                const SizedBox(height: 8),

                                /// SURNAME
                                InfoTextField(
                                  title: "surname".tr(),
                                  controller: surnameController,
                                  boxColor: const Color(0xffE0EAFF),

                                  fillSpace: true,
                                  hintText: "-",
                                  onChanged: (val) {
                                    notifier.state = ref.read(patientFilterProvider).copyWith(surname: val);
                                  },
                                ),

                                const SizedBox(height: 8),

                                /// GENDER
                                Row(children: [Text("gender".tr(), textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold))]),
                                const Gap(3),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ToggleButton(
                                        text: "male".tr(),
                                        isActive: filter.male,
                                        icon: Icons.male,
                                        activeColor: const Color(0xff5C9FEE),
                                        inactiveColor: const Color(0xffE0EAFF),
                                        onToggle: (value) {
                                          final current = ref.read(patientFilterProvider);

                                          ref.read(patientFilterProvider.notifier).state = current.copyWith(male: value);
                                        },
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: ToggleButton(
                                        text: "female".tr(),
                                        isActive: filter.female,
                                        icon: Icons.female,
                                        activeColor: const Color(0xffD63A67),
                                        inactiveColor: const Color(0xffF9AEC3),
                                        onToggle: (value) {
                                          final current = ref.read(patientFilterProvider);

                                          ref.read(patientFilterProvider.notifier).state = current.copyWith(female: value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// HN + BED
                                Row(
                                  children: [
                                    Expanded(
                                      child: InfoTextField(
                                        title: "hn".tr(),
                                        controller: hnController,
                                        boxColor: const Color(0xffE0EAFF),

                                        fillSpace: true,
                                        hintText: "-",
                                        onChanged: (val) {
                                          notifier.state = ref.read(patientFilterProvider).copyWith(hn: val);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: InfoTextField(
                                        title: "bedNumber".tr(),
                                        controller: bedController,
                                        boxColor: const Color(0xffE0EAFF),

                                        fillSpace: true,
                                        hintText: "-",
                                        onChanged: (val) {
                                          notifier.state = ref.read(patientFilterProvider).copyWith(bedNumber: val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// WARD
                                InfoTextField(
                                  title: "ward".tr(),
                                  controller: wardController,
                                  boxColor: const Color(0xffE0EAFF),

                                  fillSpace: true,
                                  hintText: "-",
                                  onChanged: (val) {
                                    notifier.state = ref.read(patientFilterProvider).copyWith(ward: val);
                                  },
                                ),

                                const SizedBox(height: 8),

                                /// AGE LABEL
                                Align(alignment: Alignment.centerLeft, child: Text("age".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),

                                /// AGE SLIDER (kept old behavior style)
                                Consumer(
                                  builder: (context, ref, _) {
                                    final filter = ref.watch(patientFilterProvider);

                                    return RangeSlider(
                                      values: filter.ageRange,
                                      min: 0,
                                      max: 120,
                                      divisions: 120,
                                      labels: RangeLabels('${filter.ageRange.start.toInt()} ${"yrs".tr()}', '${filter.ageRange.end.toInt()} ${"yrs".tr()}'),
                                      onChanged: (values) {
                                        notifier.state = ref.read(patientFilterProvider).copyWith(ageRange: values);
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        resetPatientFilter(
                                          ref: ref,
                                          nameController: nameController,
                                          surnameController: surnameController,
                                          wardController: wardController,
                                          hnController: hnController,
                                          bedController: bedController,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: const CircleBorder()),
                                      child: FaIcon(FontAwesomeIcons.arrowsRotate, color: Colors.white),
                                    ),
                                    const Gap(4),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff407BFF),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text('filterData'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    },
  );
}
