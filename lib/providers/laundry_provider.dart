import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laundry_model.dart';

class LaundryProvider extends ChangeNotifier {
  late AppData _data;
  bool _loaded = false;

  AppData get data => _data;
  bool get loaded => _loaded;
  List<LaundryCategory> get categories => _data.categories;
  bool get isDarkMode => _data.isDarkMode;

  LaundryProvider() {
    _data = AppData.defaults();
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('laundry_data');
    if (raw != null) {
      try {
        _data = AppData.fromJsonString(raw);
      } catch (_) {
        _data = AppData.defaults();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('laundry_data', _data.toJsonString());
  }

  void addClothes(String categoryId) {
    final cat = _data.categories.firstWhere((c) => c.id == categoryId);
    cat.addItem();
    _saveToDisk();
    notifyListeners();
  }

  void markWashed(String categoryId) {
    final cat = _data.categories.firstWhere((c) => c.id == categoryId);
    cat.markWashed();
    _saveToDisk();
    notifyListeners();
  }

  void setWashInterval(String categoryId, int days) {
    final cat = _data.categories.firstWhere((c) => c.id == categoryId);
    cat.washIntervalDays = days;
    _saveToDisk();
    notifyListeners();
  }

  void toggleDarkMode() {
    _data.isDarkMode = !_data.isDarkMode;
    _saveToDisk();
    notifyListeners();
  }

  void resetAll() {
    _data = AppData.defaults();
    _saveToDisk();
    notifyListeners();
  }
}
