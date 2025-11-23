// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isToggling = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  ThemeProvider() {
    Future.microtask(() => _loadTheme());
  }

  Future<void> toggleTheme(bool isOn) async {
    if (_isToggling || _isDarkMode == isOn) return;
    _isToggling = true;

    final String eventName = isOn ? 'lightmode' : 'darkmode'; // ← KAMU MAU INI!

    _isDarkMode = isOn;
    await _saveTheme();
    notifyListeners();

    // LOG SESUAI PERMINTAANMU
    await _analytics.logEvent(
      name: eventName,
      parameters: {
        'source': 'profile_page',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _isToggling = false;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}