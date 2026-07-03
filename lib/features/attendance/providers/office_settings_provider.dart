// ============================================================
// 📁 lib/features/attendance/providers/office_settings_provider.dart
// ============================================================
// Manages office settings state and persistence.
// ============================================================

import 'package:flutter/material.dart';
import '../models/office_settings_model.dart';

class OfficeSettingsProvider extends ChangeNotifier {
  OfficeSettings _settings = OfficeSettings.defaultSettings;

  OfficeSettings get settings => _settings;

  void updateSettings(OfficeSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void updateRadius(double radius) {
    _settings = _settings.copyWith(allowedRadiusMeters: radius);
    notifyListeners();
  }

  // In a real app, we would load/save from SharedPreferences or an API
  Future<void> loadSettings() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
  }

  Future<void> saveSettings() async {
    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}
