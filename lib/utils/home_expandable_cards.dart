import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/mainpage/patient_data/patient_ind_data.dart';
import 'package:pulse/utils/action_button.dart';
import 'package:pulse/utils/edit_patient_form.dart';
import 'package:pulse/utils/patient_details.dart';
import 'package:pulse/utils/toggle_icon_button.dart';

class HomeExpandableCards extends StatefulWidget {
  final List filteredPatients;
  final BuildContext context;
  final List isExpanded;

  const HomeExpandableCards({
    super.key,
    required this.filteredPatients,
    required this.context,
    required this.isExpanded,
  });

  @override
  _HomeExpandableCardsState createState() => _HomeExpandableCardsState();
}

class _HomeExpandableCardsState extends State<HomeExpandableCards> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List isExpanded = widget.isExpanded;
    List filteredPatients = widget.filteredPatients;
    return ListView.builder(
      itemCount: filteredPatients.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> patient = filteredPatients[index];
        List<String> nameParts = patient["fullname"].split(' ');
        String name = nameParts[0];
        String surname = nameParts[1];
        String age = patient["age"].toString();
        String gender = patient["gender"];
        String hn = patient["hospital_number"];
        String bedNum = patient["bed_number"];
        String ward = patient["ward"];
        // String MEWs = patient.MEWs.toString();
        String MEWs = patient["MEWs"] ?? '-';
        String pId = patient['patient_id'];
        // String time = DateFormat(
        //   'dd/MM/yyyy HH.mm',
        // ).format(patient.lastUpdate);
        String time = patient['inspectionTime'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
          child: Stack(
            children: [
              // Expanded Content
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded[index] = !isExpanded[index];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.only(top: 16),
                        height: isExpanded[index] ? 380 : 82,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff98B1E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            isExpanded[index]
                                ? PatientIndData(
                                  age: age,
                                  gender: gender.tr(),
                                  hn: hn,
                                  bedNum: bedNum,
                                  ward: ward,
                                  MEWs: MEWs,
                                  time: time,
                                )
                                : const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),

              // Collapsed Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffE0EAFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0, // Adjust the vertical position
                      right: 0, // Adjust the horizontal position
                      child: IgnorePointer(
                        child: Image.asset(
                          "assets/images/therapy3.png",
                          // width: 100, // Adjust the image size
                          // height: 100, // Adjust the image size
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isExpanded[index] = !isExpanded[index];
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$name $surname",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ), // Shadow color with opacity
                                              offset: const Offset(
                                                0.8,
                                                0.8,
                                              ), // Horizontal and vertical offset
                                              blurRadius: 1, // Blur radius
                                            ),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${"bedNumber".tr()} ",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  bedNum, // Another styled text
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "${"latestInspection".tr()} $time${"n".tr()}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                                ToggleIconButton(
                                  addPatientFunc: () async {
                                    // await addPatientID(pId);
                                    setState(
                                      () {},
                                    ); // Force a rebuild after adding
                                    print('Added $pId');
                                  },
                                  removePatientFunc: () async {
                                    // await removePatientID(pId);
                                    setState(
                                      () {},
                                    ); // Force a rebuild after removal
                                    print('Removed $pId');
                                  },
                                  buttonState: true,
                                  // monitoredPatientIDs.contains(pId)
                                  //     ? false
                                  //     : true,
                                ),
                                const SizedBox(width: 8),
                                buildActionButton(
                                  FontAwesomeIcons.clipboardList,
                                  () {
                                    showPatientDetails(context, patient);
                                  },
                                  Colors.white,
                                  const Color(0xff3362CC),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return EditPatientForm(
                                            name: name,
                                            surname: surname,
                                            age: age,
                                            gender: gender,
                                            hn: hn,
                                            bedNum: bedNum,
                                            ward: ward,
                                          );
                                        },
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white, // White background
                                      side: const BorderSide(
                                        color: Colors.white,
                                      ), // Blue border
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ), // Rounded corners
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 4,
                                      ), // Padding
                                    ),
                                    child: Text(
                                      "edit".tr(),
                                      style: const TextStyle(
                                        color: Color(0xff3362CC), // Blue text
                                        fontSize: 16, // Font size
                                        fontWeight:
                                            FontWeight.bold, // Font weight
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 69, // Adjust the position to fit your layout
                left: size.width / 2.6,
                child: Row(
                  children: [
                    InkWell(
                      child: Text("details".tr()),
                      onTap: () {
                        setState(() {
                          isExpanded[index] = !isExpanded[index];
                        });
                      },
                    ), // This stays in place
                    Icon(
                      isExpanded[index] ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ),

              // Assess Text and Icon
            ],
          ),
        );
      },
    );
  }
}
