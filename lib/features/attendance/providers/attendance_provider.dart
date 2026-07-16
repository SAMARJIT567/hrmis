// ============================================================
// 📁 lib/features/attendance/providers/attendance_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages attendance state and filtering.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/attendance_model.dart';
import '../../../core/services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AttendanceRecord> _records = [];
  List<AttendanceRecord> _filtered = [];
  bool _isLoading = false;
  String _filterStatus = 'All';

  List<AttendanceRecord> get records => _filtered;
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;

  int get presentCount => _records.where((r) => r.status == 'present').length;
  int get absentCount => _records.where((r) => r.status == 'absent').length;
  int get lateCount => _records.where((r) => r.status == 'late').length;
  int get leaveCount => _records.where((r) => r.status == 'leave').length;
  int get totalCount => _records.length;

  AttendanceProvider() {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    bool isAdmin = true;
    if (userJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(userJson);
        isAdmin = data['role']?.toString().toLowerCase() == 'admin';
      } catch (_) {}
    }

    if (isAdmin) {
      _records = List.from(AttendanceMockData.todayRecords);
    } else {
      try {
        final todayStr = DateTime.now().toString().substring(0, 10);
        final response = await _apiService.getAdminAttendance(date: todayStr);
        if (response['status'] == 'success' && response['data'] != null) {
          final List<dynamic> list = response['data'];
          _records = list.map((json) => AttendanceRecord(
            id: json['id']?.toString() ?? '',
            employeeId: json['employee_id'] ?? '',
            employeeName: json['employee_name'] ?? '',
            department: json['department'] ?? '',
            date: json['date'] ?? '',
            checkIn: json['check_in'],
            checkOut: json['check_out'],
            status: json['status'] ?? 'absent',
            workHours: json['work_hours'],
            remarks: json['remarks'],
            checkInSelfie: json['check_in_selfie'],
            checkOutSelfie: json['check_out_selfie'],
            checkInLocation: json['check_in_location'],
            checkOutLocation: json['check_out_location'],
            latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
            longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
          )).toList();
        } else {
          _records = List.from(AttendanceMockData.todayRecords);
        }
      } catch (e) {
        debugPrint('❌ Error loading admin attendance: $e');
        _records = List.from(AttendanceMockData.todayRecords);
      }
    }

    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (_filterStatus == 'All') {
      _filtered = List.from(_records);
    } else {
      _filtered = _records
          .where((r) => r.status.toLowerCase() == _filterStatus.toLowerCase())
          .toList();
    }
    notifyListeners();
  }
}