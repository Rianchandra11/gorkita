import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/database/firebase_option.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uts_backend/pages/splash.dart';
import 'package:uts_backend/providers/provider.dart';
import 'package:uts_backend/providers/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Inisialisasi Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  try {
    await initializeDateFormatting('id_ID', null);
    if (kDebugMode) debugPrint('Date formatting initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('Error initializing date formatting: $e');
  } 

  try {
    final authProvider = AuthProvider();
    await authProvider.initialize();
    if (kDebugMode) debugPrint('AuthProvider initialized');

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
    if (kDebugMode) debugPrint('Error initializing AuthProvider: $e');
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
