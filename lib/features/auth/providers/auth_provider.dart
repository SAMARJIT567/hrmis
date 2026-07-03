// ============================================================
// 📁 lib/features/auth/providers/auth_provider.dart
// ============================================================
// 🔧 CREDENTIALS CHANGE KARNE KE LIYE SIRF YAHI EK FILE CHANGE KARO
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String designation;
  final String avatarUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.designation = '',
    this.avatarUrl = '',
  });
}

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isEmployee => _currentUser?.role == 'employee';

  AuthProvider() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _currentUser = _getUserByEmail(savedEmail);
      if (_currentUser != null) {
        _loadSavedProfileUpdates();
      }
      _isLoggedIn = _currentUser != null;
      notifyListeners();
    }
  }

  void _loadSavedProfileUpdates() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name_${_currentUser!.id}');
    final savedEmail = prefs.getString('user_email_${_currentUser!.id}');
    final savedDepartment = prefs.getString('user_department_${_currentUser!.id}');
    final savedDesignation = prefs.getString('user_designation_${_currentUser!.id}');

    if (savedName != null ||
        savedEmail != null ||
        savedDepartment != null ||
        savedDesignation != null) {
      _currentUser = AuthUser(
        id: _currentUser!.id,
        name: savedName ?? _currentUser!.name,
        email: savedEmail ?? _currentUser!.email,
        role: _currentUser!.role,
        department: savedDepartment ?? _currentUser!.department,
        designation: savedDesignation ?? _currentUser!.designation,
        avatarUrl: _currentUser!.avatarUrl,
      );
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || !email.contains('@')) {
        _errorMessage = 'Please enter a valid email address.';
        return false;
      }
      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters.';
        return false;
      }

      // ─── ADMIN LOGIN ─────────────────────────────────────────
      if (email == 'admin@hrmis.com' && password == 'password123') {
        _currentUser = _getUserByEmail(email);
        _isLoggedIn = true;
        if (rememberMe && _currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
        }
        return true;
      }

      // ─── EMPLOYEE 1 ──────────────────────────────────────────
      else if (email == 'user@hrmis.com' && password == 'password123') {
        _currentUser = _getUserByEmail(email);
        _isLoggedIn = true;
        if (rememberMe && _currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
        }
        return true;
      }

      // ─── EMPLOYEE 2 ───────────────────────────────────────────
      else if (email == 'priya@techcorp.com' && password == 'password123') {
        _currentUser = _getUserByEmail(email);
        _isLoggedIn = true;
        if (rememberMe && _currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
        }
        return true;
      }

      // ─── EMPLOYEE 3 ────────────────────────────────────────────
      else if (email == 'amit@techcorp.com' && password == 'password123') {
        _currentUser = _getUserByEmail(email);
        _isLoggedIn = true;
        if (rememberMe && _currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
        }
        return true;
      }

      // ─── EMPLOYEE 4 ───────────────────────────────────────────
      else if (email == 'sneha@techcorp.com' && password == 'password123') {
        _currentUser = _getUserByEmail(email);
        _isLoggedIn = true;
        if (rememberMe && _currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
        }
        return true;
      } else {
        _errorMessage =
            'Invalid email or password.\n\nDemo Credentials:\nAdmin: admin@hrmis.com\nEmployee: user@hrmis.com\nPassword: password123';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AuthUser? _getUserByEmail(String email) {
    final users = {
      'admin@hrmis.com': const AuthUser(
        id: 'ADMIN001',
        name: 'Admin User',
        email: 'admin@hrmis.com',
        role: 'admin',
        department: 'Human Resources',
        designation: 'System Administrator',
      ),
      'user@hrmis.com': const AuthUser(
        id: 'EMP001',
        name: 'Rahul Sharma',
        email: 'user@hrmis.com',
        role: 'employee',
        department: 'Engineering',
        designation: 'Senior Developer',
      ),
      'priya@techcorp.com': const AuthUser(
        id: 'EMP002',
        name: 'Priya Singh',
        email: 'priya@techcorp.com',
        role: 'employee',
        department: 'HR',
        designation: 'HR Manager',
      ),
      'amit@techcorp.com': const AuthUser(
        id: 'EMP003',
        name: 'Amit Verma',
        email: 'amit@techcorp.com',
        role: 'employee',
        department: 'Finance',
        designation: 'Accounts Manager',
      ),
      'sneha@techcorp.com': const AuthUser(
        id: 'EMP004',
        name: 'Sneha Patel',
        email: 'sneha@techcorp.com',
        role: 'employee',
        department: 'Design',
        designation: 'UI/UX Designer',
      ),
    };
    return users[email];
  }

  Future<void> updateCurrentUser({
    required String name,
    required String email,
    required String department,
    required String designation,
  }) async {
    if (_currentUser == null) return;

    _currentUser = AuthUser(
      id: _currentUser!.id,
      name: name,
      email: email,
      role: _currentUser!.role,
      department: department,
      designation: designation,
      avatarUrl: _currentUser!.avatarUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name_${_currentUser!.id}', name);
    await prefs.setString('user_email_${_currentUser!.id}', email);
    await prefs.setString('user_department_${_currentUser!.id}', department);
    await prefs.setString('user_designation_${_currentUser!.id}', designation);

    notifyListeners();
  }

  Future<void> updateProfileImage(String base64Image) async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_${_currentUser!.id}', base64Image);
    notifyListeners();
  }

  Future<String?> getProfileImage() async {
    if (_currentUser == null) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_${_currentUser!.id}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}