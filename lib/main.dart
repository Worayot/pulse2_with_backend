import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tuh_mews/firebase_options.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuh_mews/services/alarm_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Alarm.init();
  await AlarmService().initialize();

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(tz.local.name));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ProviderScope(
      // <-- Riverpod root
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
        path: 'lang',
        fallbackLocale: const Locale('th', 'TH'),
        child: provider.ChangeNotifierProvider(create: (context) => UserDataProvider()..loadUserData(), child: const MyApp()),
      ),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.transparent
    ..indicatorColor = Colors.blue
    ..textColor = Colors.blue
    ..maskColor = Colors.transparent
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUH MEWs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(selectedItemColor: Colors.blue, unselectedItemColor: Colors.grey),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // home: const NavigationPage(),
      home: const NavigationPage(),
      builder: EasyLoading.init(),
    );
  }
}
