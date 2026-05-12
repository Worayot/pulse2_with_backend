import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuh_mews/utils/custom_header.dart';
import 'package:tuh_mews/utils/flushbar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Header(), toolbarHeight: size.height * 0.13),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    // height: 570,
                    decoration: BoxDecoration(color: const Color(0xFFB2C2E5), borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        Positioned(bottom: 0, right: 0, child: IgnorePointer(child: Image.asset("assets/images/doctor.png", fit: BoxFit.contain))),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    const Icon(FontAwesomeIcons.backward, color: Colors.black, size: 25),
                                    const SizedBox(width: 10),
                                    Text('back'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(child: Text('aboutSoftware'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 16),
                              // White container
                              Container(
                                padding: const EdgeInsets.all(30.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3), // Position of the shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("application".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Gap(10),
                                    Text("aboutAppContent".tr(), style: const TextStyle(fontSize: 14)),
                                    const Gap(16),
                                    Text('contactDev'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Gap(10),
                                    Text("contactDevContent".tr(), style: const TextStyle(fontSize: 14)),
                                    const Gap(16),
                                    InkWell(
                                      onTap: () async {
                                        final Uri url = Uri.parse("https://tuhmews.netlify.app/");

                                        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

                                        if (!launched && context.mounted) {
                                          FlushbarService.showErrorMessage(context: context, message: 'Could not launch ${url.toString()}');
                                        }
                                      },
                                      child: Text(
                                        'policy'.tr(),
                                        style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue),
                                      ),
                                    ),
                                    const Gap(16),
                                    Text('reference'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const Gap(10),

                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.4),
                                        children: [
                                          const TextSpan(text: "Baines, E., & Kanagasundaram, N. S. (2008). "),
                                          TextSpan(
                                            text: "Early warning scores: How do you know when patients are so ill that it’s time to act? ",
                                            style: GoogleFonts.inter(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                                          ),
                                          const TextSpan(text: "BMJ, 337. ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          const TextSpan(text: "\n\nRetrieved from "),
                                          TextSpan(
                                            text: "BMJ Article (2008)",
                                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                            recognizer:
                                                TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    final Uri url = Uri.parse("http://archive.student.bmj.com/issues/08/09/education/320.php");

                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  },
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
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
