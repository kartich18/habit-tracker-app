// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../utils/storage_utils.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _isDarkMode = await StorageUtils.getDarkMode();
    _primaryColor = await StorageUtils.getPrimaryColor();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageUtils.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    await StorageUtils.savePrimaryColor(color);
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      primaryColor: _primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      // Add more theme customization here
    );
  }
}
