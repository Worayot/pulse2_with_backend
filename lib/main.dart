import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tuh_mews/firebase_options.dart';
import 'package:tuh_mews/func/string_transformer.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/provider/user_data_provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuh_mews/services/alarm_services.dart';
import 'package:upgrader/upgrader.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:alarm/alarm.dart' as am;

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
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
        path: 'lang',
        fallbackLocale: const Locale('th', 'TH'),
        child: provider.ChangeNotifierProvider(create: (context) => UserDataProvider()..loadUserData(), child: const MyApp()),
      ),
    ),
  );
  configLoading();

  Future.microtask(() => initMessaging());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(fcm.RemoteMessage message) async {
  await Firebase.initializeApp();

  final alarmService = AlarmService();
  await alarmService.initialize();

  final data = message.data;

  if (data.containsKey('time') && data.containsKey('patientID')) {
    final String patientID = data['patientID'];
    final String patientName = data['patientName'] ?? 'Unknown Patient';
    final DateTime notificationTime = DateTime.parse(data['time']);
    final DateTime now = DateTime.now();

    String stringToHash = patientID + notificationTime.toString();
    int alarmId = StringTransformer().generateID(stringToHash);

    final alarmSettings = am.AlarmSettings(
      id: alarmId,
      dateTime: notificationTime,
      assetAudioPath: AlarmService.alarmPathNormal,
      loopAudio: false,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: const am.VolumeSettings.fixed(volume: 0.8, volumeEnforced: true),
      notificationSettings: am.NotificationSettings(title: 'TUH MEWs', body: 'Remind Assess: "$patientName"', stopButton: 'Stop', icon: 'notification_icon'),
    );

    await alarmService.setAlarm(alarmSettings);

    if (notificationTime.difference(now).inMinutes > 5) {
      DateTime secondNotificationTime = notificationTime.subtract(const Duration(minutes: 5));
      String secondStringToHash = patientID + secondNotificationTime.toString();
      int secondAlarmId = StringTransformer().generateID(secondStringToHash);

      final alarmSettingsBefore = alarmSettings.copyWith(id: secondAlarmId, dateTime: secondNotificationTime);

      await alarmService.setAlarm(alarmSettingsBefore);
    }
  }
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
        home: const NavigationPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
