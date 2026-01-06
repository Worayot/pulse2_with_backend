import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:tuh_mews/models/user.dart';
import 'package:tuh_mews/services/user_services.dart';
import 'package:tuh_mews/utils/add_user_form.dart';
import 'package:tuh_mews/utils/custom_header.dart';
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

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      myUserId = prefs.getString('nurseID') ?? "N/A";
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProfileData();
    _searchController.addListener(() {
      setState(() {});
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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(automaticallyImplyLeading: false, title: SafeArea(bottom: false, child: const Header()), toolbarHeight: size.height * 0.13),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [const Icon(FontAwesomeIcons.backward), const SizedBox(width: 8), Text('back'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
                ),
              ),
              const Gap(8),
              Row(children: [Text("userManagement".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer()]),
              const Gap(8),
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
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                        prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.black),
                        filled: true,
                        fillColor: const Color(0xffCADBFF),
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const Gap(8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddUserForm();
                        },
                      );
                    },
                    child: Container(
                      height: 55,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: const Color(0xff407bff), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.personCirclePlus, size: 26, color: Colors.white),
                          const Gap(8),
                          Text("addUser".tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), softWrap: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                          user: User(fullname: user['fullname'], nurseId: user['nurse_id'], password: user['password'], role: user['role']),
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
      ),
    );
  }
}
