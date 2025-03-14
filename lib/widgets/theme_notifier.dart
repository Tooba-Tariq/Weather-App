import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool isDarkMode = false;
  bool isCelsius = true;

  ThemeData get currentTheme =>
      isDarkMode ? ThemeData.dark() : ThemeData.light();

  void setTheme({required bool isDarkMode}) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  void setTemperature({required bool isCelsius}) {
    this.isCelsius = isCelsius;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
