import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uts_backend/database/firebase_option.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uts_backend/controllers/notification_controller.dart';
import 'package:uts_backend/providers/booking_reminder_provider.dart';
import 'package:uts_backend/providers/unread_notification_provider.dart';
import 'package:uts_backend/insert_dummy.dart';
import 'package:uts_backend/pages/booking/choose_booking_schedule_screen.dart';
import 'package:uts_backend/pages/home.dart';
import 'package:uts_backend/pages/notification_screen.dart';
import 'package:uts_backend/pages/splash.dart';
import 'package:uts_backend/database/providers/provider.dart';
import 'package:uts_backend/database/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uts_backend/pages/venue_detail_screen.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'unread_reminder_channel',
      channelName: 'Pengingat Pesan Belum Dibaca',
      channelDescription:
          'Notifikasi pengingat jika masih ada pesan yang belum dibaca',
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
      ledColor: Colors.white,
    ),
    NotificationChannel(
      channelKey: 'booking_reminder_channel',
      channelName: 'Pengingat Waktu Booking',
      channelDescription: 'Notifikasi pengingat jika mendekati waktu booking',
      importance: NotificationImportance.High,
      defaultColor: Colors.blue,
      ledColor: Colors.white,
    ),
  ], debug: true);

  try {
    try {
      Firebase.app();
      print('Firebase app already exists, skipping initialization');
    } catch (e) {
      print('Initializing Firebase...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      print('Firebase initialized successfully');
    }
  } catch (e) {
    print('Error with Firebase: $e');
  }

  // Inisialisasi Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  try {
    await initializeDateFormatting('id_ID', null);
    print('Date formatting initialized');
  } catch (e) {
    print('Error initializing date formatting: $e');
  }

  try {
    final authProvider = AuthProvider();
    await authProvider.initialize();
    print('AuthProvider initialized');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UnreadNotificationProvider()),
          ChangeNotifierProvider(create: (_) => BookingReminderProvider()),
        ],
        child: MyApp(analytics: analytics),
      ),
    );
  } catch (e) {
    print('Error initializing AuthProvider: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: MyApp(analytics: analytics),
      ),
    );
  }
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
    // Ambil provider tema
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomeScreen(id: 0));

          case '/notification_screen':
            return MaterialPageRoute(
              builder: (context) {
                return NotificationScreen();
              },
            );

          default:
            assert(false, 'Page ${settings.name} not found');
            return null;
        }
      },
      // home: HomeScreen(id: 0),
    );
  }
}
