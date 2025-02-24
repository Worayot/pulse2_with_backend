import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/utils/custom_header.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String _name = "";
  String _nurseID = "";
  String _role = "";
  String _password = "";

  // Track if a field is being edited
  bool _isEditingName = false;
  bool _isEditingPassword = false;

  // Controllers to track TextField changes
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "N/A";
      _role = prefs.getString('role') ?? "N/A";
      _password = prefs.getString('password') ?? "N/A";
      _nurseID = prefs.getString('nurseID') ?? "N/A";

      // Initialize the controllers with saved data
      _nameController.text = _name;
      _passwordController.text = _password;
    });
  }

  // Future<void> _saveProfileData(String key, String value) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(key, value);
  // }

  void _toggleEditMode(String field) {
    setState(() {
      if (field == 'name') {
        _isEditingName = !_isEditingName;
        if (!_isEditingName) {
          _saveName('name', _nameController.text);
        }
      } else if (field == 'password') {
        _isEditingPassword = !_isEditingPassword;
        if (!_isEditingPassword) {
          _savePassword('password', _passwordController.text);
        }
      }
    });
  }

  void _saveName(String field, String newValue) {
    if (field == 'name') {
      _name = newValue;
      _isEditingName = !_isEditingName;
      saveStringPreference('name', newValue, context);
    }
    setState(() {});
  }

  void _savePassword(String field, String newValue) {
    if (field == 'password') {
      _password = newValue;
      _isEditingPassword = !_isEditingPassword;
      saveStringPreference('password', newValue, context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Header(),
        toolbarHeight: size.height * 0.13,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              height: size.height * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFFB2C2E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.backward,
                                color: Colors.black,
                                size: 25,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'back'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "userAccount".tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35), // White box outer padding
                        child: Container(
                          height: size.height * 0.5,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () => _toggleEditMode('name'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'name-surname'.tr(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                height: 20,
                                                child: _isEditingName
                                                    ? TextField(
                                                        controller:
                                                            _nameController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              UnderlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  bottom: 13),
                                                        ),
                                                      )
                                                    : Text(
                                                        _name,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _isEditingName
                                              ? Transform.translate(
                                                  offset: const Offset(8.0,
                                                      0.0), // Move 8 pixels to the right
                                                  child: IconButton(
                                                    onPressed: () => _saveName(
                                                        'name',
                                                        _nameController.text),
                                                    icon: const Icon(
                                                        FontAwesomeIcons
                                                            .chevronRight),
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3), // Adjusted spacing

                                InkWell(
                                  onTap: () => _toggleEditMode('password'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'password'.tr(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                height: 20,
                                                child: _isEditingPassword
                                                    ? TextField(
                                                        controller:
                                                            _passwordController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              UnderlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  bottom: 13),
                                                        ),
                                                      )
                                                    : Text(
                                                        _password,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                              )
                                            ],
                                          ),
                                        ),
                                        // Align icons
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _isEditingPassword
                                              ? Transform.translate(
                                                  offset: const Offset(8.0,
                                                      0.0), // Move 8 pixels to the right
                                                  child: IconButton(
                                                    onPressed: () =>
                                                        _savePassword(
                                                            'password',
                                                            _passwordController
                                                                .text),
                                                    icon: const Icon(
                                                        FontAwesomeIcons
                                                            .chevronRight),
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3), // Adjusted spacing

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'role'.tr(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _role.tr(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9), // Adjusted spacing

                                // Nurse ID
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'nurseID'.tr(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(
                                              height: 4), // Balanced spacing
                                          Text(
                                            _nurseID,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: -50,
                    right: -30,
                    child: IgnorePointer(
                      child: Image.asset(
                        "assets/images/ambulance.png",
                        width: size.width * 0.62, // Set width
                        height: size.width * 0.62, // Set height
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
