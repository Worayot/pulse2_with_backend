import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/utils/custom_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectPage extends StatefulWidget {
  @override
  _LanguageSelectPageState createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSelectedLocale(); // Load saved locale when page loads
  }

  // Load saved locale from shared preferences
  Future<void> _loadSelectedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    final String? countryCode = prefs.getString('countryCode');

    if (languageCode != null && countryCode != null) {
      setState(() {
        _selectedLocale = Locale(languageCode, countryCode);
        context.setLocale(_selectedLocale!); // Apply the saved locale
      });
    } else {
      _selectedLocale =
          context.locale; // Set to current locale if no saved data
    }
  }

  // Save the selected locale to shared preferences
  Future<void> _saveSelectedLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // Set initial locale if not already set
    _selectedLocale ??= context.locale;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the default back button
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
              height: size.height * 0.72,
              decoration: BoxDecoration(
                color: const Color(0xFFB2C2E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16),
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
                        // Center the header text
                        child: Text(
                          'language'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Buttons for selecting language
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _onLanguageSelected(
                                      const Locale(
                                          'th', 'TH')), // Change to Thai
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Adjust height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Radius 15
                                    ),
                                    backgroundColor:
                                        _selectedLocale?.languageCode == 'th'
                                            ? const Color(0xff407BFF)
                                            : Colors.grey[300],
                                  ),
                                  child: Align(
                                    alignment: Alignment
                                        .centerLeft, // Align text to the left
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0), // Add padding
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'ไทย',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: _selectedLocale
                                                          ?.languageCode ==
                                                      'th'
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 1,
                                    bottom: 0,
                                    child: IgnorePointer(
                                        child: Image.asset(
                                            "assets/images/flags/thai_flag.png"))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _onLanguageSelected(
                                      const Locale(
                                          'en', 'US')), // Change to English
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Adjust height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Radius 15
                                    ),
                                    backgroundColor:
                                        _selectedLocale?.languageCode == 'en'
                                            ? const Color(0xff407BFF)
                                            : Colors.grey[300],
                                  ),
                                  child: Align(
                                    alignment: Alignment
                                        .centerLeft, // Align text to the left
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0), // Add padding
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'English',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: _selectedLocale
                                                          ?.languageCode ==
                                                      'en'
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 1,
                                    bottom: 0,
                                    child: IgnorePointer(
                                        child: Image.asset(
                                            "assets/images/flags/eng_flag.png")))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      right: -5,
                      bottom: 0,
                      child: IgnorePointer(
                          child: Image.asset(
                        "assets/images/med_care.png",
                        height: size.width * 0.75,
                        width: size.width * 0.75,
                      )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLanguageSelected(Locale locale) {
    setState(() {
      _selectedLocale = locale; // Update the selected locale
      context.setLocale(locale); // Apply the new locale
      _saveSelectedLocale(locale); // Save the locale to preferences
    });
  }
}
