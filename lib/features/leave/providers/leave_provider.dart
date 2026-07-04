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

  List<LeavePolicy> _policies = [
    const LeavePolicy(id: 'CL', title: 'Casual Leave', description: 'Used for unplanned personal matters or short-term needs.', totalDays: 12, usedDays: 4, iconName: 'event_note_rounded', colorValue: 0xFF1E40AF),
    const LeavePolicy(id: 'SL', title: 'Sick Leave', description: 'Used for health issues; requires certificate for 3+ days.', totalDays: 10, usedDays: 2, iconName: 'medical_services_outlined', colorValue: 0xFFEF4444),
    const LeavePolicy(id: 'EL', title: 'Earned Leave', description: 'Earned leaves for planned vacations and long rests.', totalDays: 15, usedDays: 5, iconName: 'beach_access_rounded', colorValue: 0xFF10B981),
    const LeavePolicy(id: 'ML', title: 'Maternity Leave', description: 'Paid leave for expecting mothers (continuous block).', totalDays: 182, usedDays: 0, iconName: 'pregnant_woman_rounded', colorValue: 0xFF7C3AED),
    const LeavePolicy(id: 'PL', title: 'Paternity Leave', description: 'Granted to male employees around spouse delivery.', totalDays: 15, usedDays: 0, iconName: 'child_care_rounded', colorValue: 0xFF0EA5E9),
    const LeavePolicy(id: 'CO', title: 'Compensatory Off', description: 'Credit for working on holidays or weekly off days.', totalDays: 5, usedDays: 1, iconName: 'celebration_rounded', colorValue: 0xFFF59E0B),
    const LeavePolicy(id: 'BL', title: 'Bereavement Leave', description: 'Granted during a family tragedy or mourning.', totalDays: 5, usedDays: 0, iconName: 'heart_broken_rounded', colorValue: 0xFF475569),
  ];

  List<LeaveRequest> get requests => _filtered;
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;
  List<LeavePolicy> get policies => _policies;

  void updatePolicy(String id, int newTotal) {
    final idx = _policies.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _policies[idx] = _policies[idx].copyWith(totalDays: newTotal);
      notifyListeners();
    }
  }

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