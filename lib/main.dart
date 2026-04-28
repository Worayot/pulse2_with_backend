import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/firebase_options.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AlarmService().initialize();

  tzdata.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  // 🔥 Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await EasyLocalization.ensureInitialized();

  // 📱 Lock orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
        path: 'lang',
        fallbackLocale: const Locale('th', 'TH'),
        child: provider.ChangeNotifierProvider(create: (context) => UserDataProvider()..loadUserData(), child: const MyApp()),
      ),
    ),
  );

  configLoading();

  // Optional: keep FCM token logging
  Future.microtask(() => initMessaging());
  return null;
}

Future<void> initMessaging() async {
  if (Platform.isAndroid) {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token (Android): $token");
    return;
  }

  if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint("Permission denied");
      return;
    }

    try {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      if (apnsToken == null) {
        debugPrint("iOS Simulator detected → skipping FCM token");
        return;
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token (iOS): $fcmToken");
    } catch (e) {
      debugPrint("FCM skipped (likely simulator): $e");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint("Token updated: $token");
    });
  }
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..maskType = EasyLoadingMaskType.custom
    ..backgroundColor = Colors.transparent
    ..boxShadow = []
    ..indicatorColor = Colors.lightBlueAccent
    ..maskColor = Colors.transparent
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..textColor = Colors.white
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final upgrader = Upgrader(
      debugLogging: true,
      countryCode: 'TH',
      debugDisplayAlways: false,
      durationUntilAlertAgain: const Duration(days: 1),
      messages: null,
      storeController: UpgraderStoreController(onAndroid: () => UpgraderPlayStore(), oniOS: () => UpgraderAppStore()),
    );

    return UpgradeAlert(
      upgrader: upgrader,
      barrierDismissible: false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TUH MEWs',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey),
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: FirebaseAuth.instance.currentUser == null ? LoginPage() : NavigationPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
