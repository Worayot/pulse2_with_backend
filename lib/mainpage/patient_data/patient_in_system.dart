import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:pulse/services/fetch_mews.dart';
import 'package:pulse/mainpage/patient_data/no_patient_screen.dart';
import 'package:pulse/universal_setting/sizes.dart';
import 'package:pulse/utils/home_expandable_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/add_patient_form.dart';

class PatientInSystem extends StatefulWidget {
  const PatientInSystem({super.key});

  @override
  _PatientInSystemState createState() => _PatientInSystemState();
}

class _PatientInSystemState extends State<PatientInSystem> {
  List<String> monitoredPatientIDs = [];
  bool isLoading = true;
  final List<bool> _isExpanded = [];
  final List<bool> isPlus = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _loadMonitoredPatients() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      monitoredPatientIDs = await prefs.getStringList('patient_ids') ?? [];
      // print('Loaded monitored patients: $monitoredPatientIDs');
    } catch (e) {
      print('Error loading preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patient list: $e')),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      // print('Before loading: $monitoredPatientIDs');
      await _loadMonitoredPatients();
      // print('After loading: $monitoredPatientIDs');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPatients(
    List<Map<String, dynamic>> patients,
  ) {
    if (_searchQuery.isEmpty) return patients;

    return patients
        .where(
          (patient) =>
              patient["fullname"]?.toString().toLowerCase().contains(
                _searchQuery,
              ) ??
              false,
        )
        .toList();
  }

  // Stream to listen to real-time updates from Firestore
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
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    SearchBarSetting sbs = SearchBarSetting(context: context);
    ButtonNextToSearchBarSetting btnsb = ButtonNextToSearchBarSetting(
      context: context,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: sbs.getHeight(),
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
                                    },
                                  )
                                  : null,
                          fillColor: const Color(0xffCADBFF),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Colors.black,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddPatientForm();
                        },
                      );
                    },
                    icon: Icon(
                      FontAwesomeIcons.userPlus,
                      color: Colors.white,
                      size: screenWidth * 0.07,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        "addPatient".tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff407BFF),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: btnsb.verticalPadding(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      fixedSize: Size.fromHeight(sbs.getHeight()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                  final filteredPatients = _getFilteredPatients(patients);

                  // Synchronize _isExpanded with filteredPatients
                  if (_isExpanded.length != filteredPatients.length) {
                    // Create a new list to preserve the state of existing patients
                    List<bool> newIsExpanded = [];
                    List<bool> newIsPlus = [];
                    for (var patient in filteredPatients) {
                      int index = patients.indexOf(patient);
                      bool isMonitored = monitoredPatientIDs.contains(
                        patient['patient_id'],
                      );
                      print(
                        'Patient ID: ${patient['patient_id']}, isMonitored: $isMonitored',
                      );

                      if (index != -1 && index < _isExpanded.length) {
                        newIsExpanded.add(_isExpanded[index]);
                        newIsPlus.add(isMonitored);
                      } else {
                        newIsExpanded.add(false);
                        newIsPlus.add(true);
                      }
                    }

                    _isExpanded.clear();
                    _isExpanded.addAll(newIsExpanded);
                    isPlus.clear();
                    isPlus.addAll(newIsPlus);
                  }
                  // print('Filtered Patients: ${filteredPatients.length}');
                  // print('Is Expanded List: ${_isExpanded.length}');
                  // print('Is Expanded List Contents: $_isExpanded');
                  // print('isPlus: $isPlus');
                  // print('monitor: $monitoredPatientIDs');

                  return HomeExpandableCards(
                    filteredPatients: filteredPatients,
                    context: context,
                    isExpanded: _isExpanded,
                    isPlus: isPlus,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
