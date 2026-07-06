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
    const LeavePolicy(id: 'CL', title: 'Casual Leave', description: 'Assam Govt: 12 days/year. No carry forward. Not a regular leave. Cannot be clubbed with EL/Medical. Sundays/Holidays in between are NOT counted.', totalDays: 12, usedDays: 4, iconName: 'event_note_rounded', colorValue: 0xFF1E40AF),
    const LeavePolicy(id: 'COL', title: 'Commuted Leave', description: 'Medical ground leave with Full Pay. Note: 1 day Commuted Leave = 2 days HPL deduction. Medical certificate mandatory.', totalDays: 120, usedDays: 10, iconName: 'medical_services_outlined', colorValue: 0xFFEF4444),
    const LeavePolicy(id: 'HPL', title: 'Half Pay Leave', description: 'Earned at 20 days/year. Provides Half Salary. Can be converted to Commuted Leave for Full Pay (2:1 ratio).', totalDays: 60, usedDays: 20, iconName: 'history_edu_rounded', colorValue: 0xFFF59E0B),
    const LeavePolicy(id: 'EL', title: 'Earned Leave', description: 'Assam Govt Rules: 30 days/year (15+15 credit). Max 300 days accumulation. Sandwich rule applies. No clubbing with CL.', totalDays: 30, usedDays: 5, iconName: 'beach_access_rounded', colorValue: 0xFF10B981),
    const LeavePolicy(id: 'ML', title: 'Maternity Leave', description: 'Paid leave for expecting mothers (continuous block).', totalDays: 182, usedDays: 0, iconName: 'pregnant_woman_rounded', colorValue: 0xFF7C3AED),
    const LeavePolicy(id: 'PL', title: 'Paternity Leave', description: 'Granted to male employees around spouse delivery.', totalDays: 15, usedDays: 0, iconName: 'child_care_rounded', colorValue: 0xFF0EA5E9),
    const LeavePolicy(id: 'CO', title: 'Compensatory Leave', description: 'Credit for working on holidays or weekly off days.', totalDays: 5, usedDays: 1, iconName: 'celebration_rounded', colorValue: 0xFFF59E0B),
    const LeavePolicy(id: 'BL', title: 'Bereavement Leave', description: 'Granted during a family tragedy or mourning.', totalDays: 5, usedDays: 0, iconName: 'heart_broken_rounded', colorValue: 0xFF475569),
    const LeavePolicy(id: 'RH', title: 'Restricted Holiday', description: 'Assam Govt: 2 days/year. Optional holidays selected from a predefined list. Can be clubbed with CL.', totalDays: 2, usedDays: 0, iconName: 'festival_rounded', colorValue: 0xFFD946EF),
  ];

  final List<Map<String, String>> _restrictedHolidaysList = [
    {'name': 'Ali-Aye-Ligang', 'date': '19 Feb 2025'},
    {'name': 'Bizu Festival', 'date': '13 Apr 2025'},
    {'name': 'Sati Sadhani Divas', 'date': '21 Apr 2025'},
    {'name': 'Mahabir Jayanti', 'date': '10 Apr 2025'},
    {'name': 'Tithi of Damodar Dev', 'date': '28 Apr 2025'},
    {'name': 'Buddha Purnima', 'date': '12 May 2025'},
    {'name': 'Death Anniv. of Madhab Dev', 'date': '12 Aug 2025'},
    {'name': 'Karam Puja', 'date': '04 Sep 2025'},
    {'name': 'Martyrdom Day of Guru Tegh Bahadur', 'date': '24 Nov 2025'},
  ];

  List<LeaveRequest> get requests => _filtered;
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;
  List<LeavePolicy> get policies => _policies;
  List<Map<String, String>> get restrictedHolidaysList => _restrictedHolidaysList;

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