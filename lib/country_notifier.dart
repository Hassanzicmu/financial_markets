import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryNotifier extends ChangeNotifier {
  String _country = 'eg'; // Default to Egypt

  String get country => _country;

  CountryNotifier() {
    _loadCountry();
  }

  void _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCountry = prefs.getString('selectedCountry');
    if (savedCountry != null) {
      _country = savedCountry;
      notifyListeners();
    }
  }

  Future<void> changeCountry(String newCountry) async {
    if (_country == newCountry) return;
    _country = newCountry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', newCountry);
    notifyListeners();
  }
}
