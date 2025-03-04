import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/authentication/login.dart';
import 'package:pulse/func/pref/pref.dart';
import 'package:pulse/mainpage/settings/aboutapp.dart';
import 'package:pulse/mainpage/settings/admin.dart';
import 'package:pulse/mainpage/settings/language.dart';
import 'package:pulse/mainpage/settings/profile.dart';
import 'package:pulse/utils/custom_header.dart';
import 'dart:io';

import 'package:pulse/utils/warning_dialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<List<Map<String, String>>> quotes; // Quotes Future

  @override
  void initState() {
    super.initState();
    quotes = loadQuotes();
  }

  Future<List<Map<String, String>>> loadQuotes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/quotes/quotes.json',
      );
      final List<dynamic> data = json.decode(response);

      // Ensure every dynamic map is safely cast to Map<String, String>
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return {
            'quote': item['quote'].toString(),
            'author': item['author'].toString(),
          };
        } else {
          throw const FormatException("Invalid JSON format");
        }
      }).toList();
    } catch (e) {
      print('Error loading quotes.json: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:
              Platform.isAndroid
                  ? EdgeInsets.only(top: size.height * 0.05)
                  : EdgeInsets.only(top: size.height * 0),
          child: const Header(),
        ),
        toolbarHeight: size.height * 0.13,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                // User Info Section
                SizedBox(height: size.height * 0.025),
                // Menu ListTiles
                _buildSettingsTile(
                  title: 'profileSetting'.tr(),
                  leadingIcon: FontAwesomeIcons.solidAddressBook,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSettingsPage(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  title: 'aboutApp'.tr(),
                  leadingIcon: FontAwesomeIcons.circleInfo,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutAppPage()),
                      ),
                ),
                _buildSettingsTile(
                  title: 'language'.tr(),
                  leadingIcon: FontAwesomeIcons.globe,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageSelectPage(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                // if (_role == "admin")
                //   _buildSettingsTile(
                //     title: 'admin'.tr(),
                //     leadingIcon: FontAwesomeIcons.userTie,
                //     onTap: () async {
                //       await Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const AdminPage()),
                //       );
                //     },
                //   ),
                FutureBuilder<String?>(
                  future: loadStringPreference('role'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading role: ${snapshot.error}');
                    } else if (snapshot.data == "admin") {
                      return _buildSettingsTile(
                        title: 'adminFeature'.tr(),
                        leadingIcon: FontAwesomeIcons.userTie,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminPage(),
                            ),
                          );
                        },
                      );
                    }
                    return Container(); // If not admin, don't show this tile
                  },
                ),
                _buildSettingsTile(
                  title: 'logout'.tr(),
                  leadingIcon: FontAwesomeIcons.rightFromBracket,
                  color: const Color(0xffFF0000),
                  onTap: () async {
                    bool shouldProceed = await showWarningDialog(context);
                    if (shouldProceed) {
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (Route<dynamic> route) =>
                            false, // Removes all previous screens
                      );
                    } else {
                      return;
                    }
                  },
                ),

                SizedBox(height: size.height * 0.05),

                // Random Quote Section using FutureBuilder
                FutureBuilder<List<Map<String, String>>>(
                  future: quotes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error loading quotes: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No quotes found.');
                    }

                    final loadedQuotes = snapshot.data!;
                    final random = Random();
                    final selectedQuote =
                        loadedQuotes[random.nextInt(loadedQuotes.length)];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width / 2.2,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '"',
                                        style: TextStyle(
                                          fontSize: size.width / 25,
                                          fontWeight: FontWeight.bold,
                                          height: size.height * 0.002,
                                        ),
                                      ),
                                      TextSpan(
                                        text: selectedQuote['quote']![0],
                                        style: TextStyle(
                                          fontSize: size.width / 15,
                                          fontWeight: FontWeight.bold,
                                          height: size.height * 0.002,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${selectedQuote['quote']!.substring(1)}"',
                                        style: TextStyle(
                                          fontSize: size.width / 25,
                                          fontWeight: FontWeight.bold,
                                          height: size.height * 0.002,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              SizedBox(
                                width: size.width * 0.45,
                                child: Text(
                                  selectedQuote['author']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -size.width * 0.1,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/hospital.png', // Ensure this path is correct
                width: size.width * 0.4, // Increased width
                height: size.height * 0.4, // Increased height
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData leadingIcon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      leading: FaIcon(leadingIcon, color: color ?? const Color(0xff3362CC)),
      trailing: FaIcon(
        FontAwesomeIcons.arrowRight,
        color: color ?? Colors.black,
      ),
      onTap: onTap,
    );
  }
}
