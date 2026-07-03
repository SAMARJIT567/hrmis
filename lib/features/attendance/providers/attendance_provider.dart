// ============================================================
// 📁 lib/features/attendance/providers/attendance_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages attendance state and filtering.
// ============================================================

import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
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
    await Future.delayed(const Duration(milliseconds: 500));
    _records = List.from(AttendanceMockData.todayRecords);
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