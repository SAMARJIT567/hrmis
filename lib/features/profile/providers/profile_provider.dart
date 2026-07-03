// ============================================================
// 📁 lib/features/profile/providers/profile_provider.dart
// ============================================================
// Manages user profile data and updates
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = false;
  String? _profileImageBase64;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get profileImage => _profileImageBase64;

  void initialize(AuthUser user) {
    _user = user;
    _loadSavedProfileImage();
    notifyListeners();
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    _profileImageBase64 = prefs.getString('profile_image_${_user?.id}');
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String department,
    required String designation,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _user = AuthUser(
      id: _user!.id,
      name: name,
      email: email,
      role: _user!.role,
      department: department,
      designation: designation,
      avatarUrl: _user!.avatarUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name_${_user!.id}', name);
    await prefs.setString('user_email_${_user!.id}', email);
    await prefs.setString('user_department_${_user!.id}', department);
    await prefs.setString('user_designation_${_user!.id}', designation);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfileImage(String base64Image) async {
    _profileImageBase64 = base64Image;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_${_user?.id}', base64Image);
    notifyListeners();
  }

  Future<void> removeProfileImage() async {
    _profileImageBase64 = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_${_user?.id}');
    notifyListeners();
  }
}