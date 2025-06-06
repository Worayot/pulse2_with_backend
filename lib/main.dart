import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuh_mews/authentication/login.dart';
import 'package:tuh_mews/firebase_options.dart';
import 'package:tuh_mews/func/notification_scheduler.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuh_mews/services/alarm_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  await AlarmService().initialize();

  tzdata.initializeTimeZones(); // Initialize timezone data
  tz.setLocalLocation(tz.getLocation(tz.local.name)); // Set local timezone
  // NotificationScheduler notificationScheduler = NotificationScheduler();
  // await notificationScheduler.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  // await initializeNotifications(); // Initialize notifications

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => UserDataProvider()..loadUserData(),
        child: EasyLocalization(
          supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
          path: 'lang',
          fallbackLocale: const Locale('th', 'TH'),
          child: const MyApp(),
        ),
      ),
    );
  });
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // home: const NavigationPage(),
      home: const LoginPage(),
    );
  }
}
