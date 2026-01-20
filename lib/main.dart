import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/database/firebase_option.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uts_backend/pages/splash.dart';
import 'package:uts_backend/database/providers/provider.dart';
import 'package:uts_backend/database/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


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
      ledColor: Colors.white,
    ),
    NotificationChannel(
      channelKey: 'location',
      channelName: 'Akses Lokasi Aktif',
      channelDescription:
          'Notifikasi pemberitahuan bahwa akses lokasi sedang diaktifikan',
      importance: NotificationImportance.Low,
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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.android,
      );
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

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const MyApp({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    // Ambil provider tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GORKITA',
      debugShowCheckedModeBanner: false,
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
      home: const SplashScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
