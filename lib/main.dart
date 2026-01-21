import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/helper/firebase_option.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uts_backend/controllers/notification_controller.dart';
import 'package:uts_backend/pages/home.dart';
import 'package:uts_backend/pages/splash.dart';
import 'package:uts_backend/providers/booking_reminder_provider.dart';
import 'package:uts_backend/providers/unread_notification_provider.dart';
import 'package:uts_backend/providers/auth_provider.dart';
import 'package:uts_backend/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uts_backend/helper/notification_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uts_backend/widgets/ad_interstitial.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'unread_reminder_channel',
      channelName: 'Pengingat Pesan Belum Dibaca',
      channelDescription:
          'Notifikasi pengingat jika masih ada pesan yang belum dibaca',
      importance: NotificationImportance.High,
      defaultColor: Colors.blue,
      locked: true,
      
      ledColor: Colors.white,
    ),
    NotificationChannel(
      channelKey: 'location_active',
      channelName: 'Akses Lokasi Aktif',
      channelDescription:
          'Notifikasi pemberitahuan bahwa akses lokasi sedang diaktifikan',
      importance: NotificationImportance.High,
      
      
      defaultColor: Colors.blue,
      ledColor: Colors.white,
    ),
    NotificationChannel(
      channelKey: 'booking_confirmation_channel',
      channelName: 'Pengingat Konfirmasi Booking Berhasil',
      channelDescription:
          'Notifikasi konfirmasi jika data booking user berhasil diinput',
      importance: NotificationImportance.High,
      defaultColor: Colors.blue,
      ledColor: Colors.white,),
    NotificationChannel(
      channelKey: 'booking_reminder_channel',
      channelName: 'Pengingat Waktu Booking',
      channelDescription: 'Notifikasi pengingat jika mendekati waktu booking',
      importance: NotificationImportance.Low,
      defaultColor: Colors.blue,
      ledColor: Colors.white,
    ),
  ], debug: true);
  try {
    try {
      Firebase.app();
      if (kDebugMode) debugPrint('Firebase app already exists, skipping initialization');
    } catch (e) {
      if (kDebugMode) debugPrint('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.android,
      );
      if (kDebugMode) debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Error with Firebase: $e');
  }

  await NotificationHelper.init();
  print('NotificationHelper initialized');

  await MobileAds.instance.initialize();
  print('Google Mobile Ads (AdMob) initialized');

  InterstitialHelper.loadAd();
  print('Interstitial Ad preloaded');

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  try {
    await initializeDateFormatting('id_ID', null);
    if (kDebugMode) debugPrint('Date formatting initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('Error initializing date formatting: $e');
  } 
  final authProvider = AuthProvider();
  await authProvider.initialize();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create:(_) => authProvider),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UnreadNotificationProvider()),
          ChangeNotifierProvider(create: (_) => BookingReminderProvider()),
        ],
        child: MyApp(analytics: analytics),
      ),
    );
}

class MyApp extends StatefulWidget {
  final FirebaseAnalytics analytics;
  const MyApp({super.key, required this.analytics});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GORKITA',
      debugShowCheckedModeBanner: false,
      navigatorKey: MyApp.navigatorKey,
      initialRoute: '/',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromRGBO(21, 116, 42, 1),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromRGBO(21, 116, 42, 1),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: widget.analytics),
      ],
      home: WelcomeScreen(),
    );
  }
}
