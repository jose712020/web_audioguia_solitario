import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaProvider extends ChangeNotifier {
  static const String _claveOscuro = 'isDarkMode';

  bool _isDarkMode = false;

  TemaProvider() {
    _cargarPreferencia();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_claveOscuro) ?? false;
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveOscuro, _isDarkMode);
  }
}
