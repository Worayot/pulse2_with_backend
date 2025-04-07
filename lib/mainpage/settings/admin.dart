import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuh_mews/models/user.dart';
import 'package:tuh_mews/services/user_services.dart';
import 'package:tuh_mews/universal_setting/sizes.dart';
import 'package:tuh_mews/utils/add_user_form.dart';
import 'package:tuh_mews/utils/custom_header.dart';
// import 'package:tuh_mews/utils/edit_user_form.dart';
import 'package:tuh_mews/utils/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserServices userServices = UserServices();

  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? accountData = {};
  String _searchText = '';
  String myUserId = '';

  // Change this to a separate method
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      myUserId = prefs.getString('nurseID') ?? "N/A";
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call the async function here
  }

  // This method runs the async function
  Future<void> _initializeData() async {
    await _loadProfileData();
    _searchController.addListener(() {
      setState(() {}); // This ensures the clear button updates dynamically
    });
  }

  void _filterUsers(String query) {
    setState(() {
      _searchText = query.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SearchBarSetting sbs = SearchBarSetting(context: context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Header(),
        toolbarHeight: size.height * 0.13,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.backward), // Back icon
                  const SizedBox(width: 8),
                  Text(
                    'back'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "userManagement".tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterUsers,
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
                                    _searchText = '';
                                  });
                                },
                              )
                              : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: const Color(0xffCADBFF),
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  // height: sbs.getHeight(),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddUserForm();
                        },
                      );
                    },
                    icon: Icon(
                      FontAwesomeIcons.personCirclePlus,
                      size: 40,
                      color: Colors.white,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "addUser".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff407bff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      // fixedSize: Size.fromHeight(sbs.getHeight()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  final users =
                      snapshot.data!.docs.where((doc) {
                        var user = doc.data() as Map<String, dynamic>;
                        var name = user['fullname'];
                        return name.toLowerCase().contains(_searchText);
                      }).toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index].data() as Map<String, dynamic>;

                      return UserCard(
                        user: User(
                          fullname: user['fullname'],
                          nurseId: user['nurse_id'],
                          password: user['password'],
                          role: user['role'],
                        ),
                        renderRemoveButton: myUserId != user['nurse_id'],
                      );
                    },
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
