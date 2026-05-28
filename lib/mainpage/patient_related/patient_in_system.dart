import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuh_mews/func/filter_patient.dart';
import 'package:tuh_mews/models/patient_filter_state.dart';
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:tuh_mews/services/fetch_mews.dart';
import 'package:tuh_mews/mainpage/patient_related/no_patient_screen.dart';
import 'package:tuh_mews/utils/patient_in_system/home_card_data.dart';
import 'package:tuh_mews/utils/patient_in_system/patient_card_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuh_mews/utils/symbols_dialog/home_symbols.dart';
import 'package:tuh_mews/utils/symbols_dialog/info_dialog.dart';
import '../../utils/add_patient_form.dart';

class PatientInSystem extends ConsumerStatefulWidget {
  const PatientInSystem({super.key});

  @override
  _PatientInSystemState createState() => _PatientInSystemState();
}

class _PatientInSystemState extends ConsumerState<PatientInSystem> {
  String userId = '';
  List<Map<String, dynamic>> allPatients = [];

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('nurseID') ?? "N/A";
    });
  }

  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _hnController = TextEditingController();
  final TextEditingController _bedController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadProfileData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _wardController.dispose();
    _hnController.dispose();
    _bedController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPatients(List<Map<String, dynamic>> patients, PatientFilterState filter) {
    return patients.where((patient) {
      final fullname = (patient["fullname"] ?? "").toString().toLowerCase();
      final ward = (patient["ward"] ?? "").toString().toLowerCase();
      final hn = (patient["hospital_number"] ?? "").toString().toLowerCase();
      final bed = (patient["bed_number"] ?? "").toString().toLowerCase();
      final gender = (patient["gender"] ?? "").toString().toLowerCase();

      final nameParts = fullname.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
      final lastName = nameParts.length > 1 ? nameParts[1] : "";

      final age = int.tryParse(patient["age"]?.toString() ?? "") ?? 0;

      final matchesSearch = _searchQuery.isEmpty || fullname.contains(_searchQuery);

      final matchesName = filter.name.isEmpty || firstName.contains(filter.name.toLowerCase());

      final matchesSurname = filter.surname.isEmpty || lastName.contains(filter.surname.toLowerCase());

      final matchesWard = filter.ward.isEmpty || ward.contains(filter.ward.toLowerCase());

      final matchesHN = filter.hn.isEmpty || hn.contains(filter.hn.toLowerCase());

      final matchesBed = filter.bedNumber.isEmpty || bed.contains(filter.bedNumber.toLowerCase());

      final matchesGender = (filter.male == filter.female) || (filter.male && gender == "male") || (filter.female && gender == "female");

      final matchesAge = age >= filter.ageRange.start && age <= filter.ageRange.end;

      return matchesSearch && matchesName && matchesSurname && matchesWard && matchesHN && matchesBed && matchesGender && matchesAge;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getPatientsStream() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference patientsCollection = firestore.collection('patients');

    return patientsCollection.snapshots().asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> fetchedPatients = [];
      List<Future<Map<String, dynamic>>> mewsFutures = [];

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        var patient = document.data() as Map<String, dynamic>;
        patient['patient_id'] = document.id;
        mewsFutures.add(fetchLatestPatientData(patient['patient_id']));
        fetchedPatients.add(patient);
      }

      List<Map<String, dynamic>> mewsResults = await Future.wait(mewsFutures);

      for (int i = 0; i < fetchedPatients.length; i++) {
        fetchedPatients[i]['MEWs'] = mewsResults[i]['mews'];
        fetchedPatients[i]['inspectionTime'] = mewsResults[i]['time'];
      }

      fetchedPatients.sort((a, b) {
        String fullNameA = a['fullname']?.toString().toLowerCase() ?? '';
        String fullNameB = b['fullname']?.toString().toLowerCase() ?? '';
        return fullNameA.compareTo(fullNameB);
      });

      return fetchedPatients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(patientFilterProvider);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: FittedBox(fit: BoxFit.scaleDown, child: Text("patientsInSystem".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    GestureDetector(
                      onTap: () {
                        showInfoDialog(context, homeSymbols());
                      },
                      child: const FaIcon(FontAwesomeIcons.circleInfo, size: 28, color: Color(0xff3362CC)),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "${"search".tr()}...",
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                    : null,
                            fillColor: const Color(0xffCADBFF),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.black),
                            prefixIconConstraints: const BoxConstraints(minWidth: 60),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),

                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AddPatientForm();
                          },
                        );
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(color: Color(0xff407BFF), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 25)),
                      ),
                    ),
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        showFilterDialog(
                          context: context,
                          ref: ref,
                          nameController: _nameController,
                          surnameController: _surnameController,
                          wardController: _wardController,
                          hnController: _hnController,
                          bedController: _bedController,
                        );
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(color: Color(0xff407BFF), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Icon(FontAwesomeIcons.filter, color: Colors.white, size: 25)),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getPatientsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return NoPatientWidget();
                      }

                      final patients = snapshot.data!;
                      allPatients = patients;
                      final filteredPatients = _getFilteredPatients(patients, filter);

                      if (filteredPatients.isEmpty) {
                        return NoPatientWidget();
                      }

                      return ListView.separated(
                        itemCount: filteredPatients.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Gap(8);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final data = filteredPatients[index];

                          final timestamp = data['created_at'];
                          DateTime? createdAt;
                          if (timestamp != null && timestamp is Timestamp) {
                            createdAt = timestamp.toDate().toLocal().toUtc();
                          }

                          final timeString = data['inspectionTime'] as String?;
                          TimeOfDay? inspectionTime;
                          if (timeString != null && timeString.contains(':')) {
                            final parts = timeString.split(':');
                            final hour = int.tryParse(parts[0]) ?? 0;
                            final minute = int.tryParse(parts[1]) ?? 0;
                            inspectionTime = TimeOfDay(hour: hour, minute: minute);
                          }

                          return HomeExpandableCards(
                            data: HomeCardData(
                              fullname: data['fullname'] as String?,
                              gender: data['gender'] as String?,
                              hn: data['hospital_number']?.toString(),
                              age: data['age']?.toString(),
                              bedNum: data['bed_number']?.toString(),
                              ward: data['ward']?.toString(),
                              mews: data['MEWs']?.toString(),
                              patientID: data['patient_id'] as String?,
                              createdAt: createdAt,
                              inspectionTime: inspectionTime,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
