// ============================================================
// 📁 lib/features/leave/providers/leave_provider.dart
// ─────────────────────────────────────────────────────────────
// Leave request state management.
// ============================================================

import 'package:flutter/material.dart';
import '../models/leave_model.dart';

class LeaveProvider extends ChangeNotifier {
  List<LeaveRequest> _all = [];
  List<LeaveRequest> _filtered = [];
  bool _isLoading = false;
  String _filter = 'All';

  List<LeaveRequest> get requests => _filtered;
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;

  int get pendingCount => _all.where((r) => r.status == 'pending').length;
  int get approvedCount => _all.where((r) => r.status == 'approved').length;
  int get rejectedCount => _all.where((r) => r.status == 'rejected').length;
  int get totalCount => _all.length;

  LeaveProvider() { loadLeaves(); }

  Future<void> loadLeaves() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _all = List.from(LeaveMockData.requests);
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  void filterBy(String status) {
    _filter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filtered = _filter == 'All'
        ? List.from(_all)
        : _all.where((r) => r.status.toLowerCase() == _filter.toLowerCase()).toList();
    notifyListeners();
  }

  void approveLeave(String id) {
    final idx = _all.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _all[idx] = LeaveRequest(
        id: _all[idx].id, employeeId: _all[idx].employeeId,
        employeeName: _all[idx].employeeName, department: _all[idx].department,
        leaveType: _all[idx].leaveType, fromDate: _all[idx].fromDate,
        toDate: _all[idx].toDate, days: _all[idx].days, reason: _all[idx].reason,
        status: 'approved', appliedOn: _all[idx].appliedOn, approvedBy: 'You',
      );
      _applyFilter();
    }
  }

  void rejectLeave(String id) {
    final idx = _all.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _all[idx] = LeaveRequest(
        id: _all[idx].id, employeeId: _all[idx].employeeId,
        employeeName: _all[idx].employeeName, department: _all[idx].department,
        leaveType: _all[idx].leaveType, fromDate: _all[idx].fromDate,
        toDate: _all[idx].toDate, days: _all[idx].days, reason: _all[idx].reason,
        status: 'rejected', appliedOn: _all[idx].appliedOn, approvedBy: 'You',
      );
      _applyFilter();
    }
  }
}