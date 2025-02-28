import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart';

class LoadingBar {
  final BuildContext context;
  final String name;
  LoadingBar({required this.context, required this.name});

  Widget build() {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          width: size.width / 1.3,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color(0xffCCE9FF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: const LinearProgressIndicator(
                                minHeight: 10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xff1125A4),
                                ),
                                backgroundColor: Color(0xffB0D3EF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 50,
                        bottom: 10,
                        child: ClipRect(
                          child: Image.asset(
                            'assets/images/turtle.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '${'welcome'.tr()}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(name, style: const TextStyle(fontSize: 20)),
                ],
              ),
              Positioned(
                right: 0,
                top: size.height / 2 - 110,
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/waiter.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
