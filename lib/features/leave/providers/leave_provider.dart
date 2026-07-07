// ============================================================
// 📁 lib/features/leave/providers/leave_provider.dart
// ─────────────────────────────────────────────────────────────
// Leave request state management.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/leave_model.dart';

class LeaveProvider extends ChangeNotifier {
  List<LeaveRequest> _all = [];
  List<LeaveRequest> _filtered = [];
  List<CompOffCredit> _compOffReports = [];
  bool _isLoading = false;
  String _filter = 'All';

  List<LeavePolicy> _policies = [
    const LeavePolicy(id: 'CL', title: 'Casual Leave', description: 'Assam Govt: 12 days/year. No carry forward. Not a regular leave. Cannot be clubbed with EL/Medical. Sundays/Holidays in between are NOT counted.', totalDays: 12, usedDays: 0, iconName: 'event_note_rounded', colorValue: 0xFF1E40AF),
    const LeavePolicy(id: 'COL', title: 'Commuted Leave', description: 'Medical ground leave with Full Pay. Note: 1 day Commuted Leave = 2 days HPL deduction. Medical certificate mandatory.', totalDays: 120, usedDays: 0, iconName: 'medical_services_outlined', colorValue: 0xFFEF4444),
    const LeavePolicy(id: 'HPL', title: 'Half Pay Leave', description: 'Earned at 20 days/year. Provides Half Salary. Can be converted to Commuted Leave for Full Pay (2:1 ratio).', totalDays: 60, usedDays: 0, iconName: 'history_edu_rounded', colorValue: 0xFFF59E0B),
    const LeavePolicy(id: 'EL', title: 'Earned Leave', description: 'Assam Govt Rules: 30 days/year (15+15 credit). Max 300 days accumulation. Sandwich rule applies. No clubbing with CL.', totalDays: 30, usedDays: 0, iconName: 'beach_access_rounded', colorValue: 0xFF10B981),
    const LeavePolicy(id: 'ML', title: 'Maternity Leave', description: 'Paid leave for expecting mothers (continuous block).', totalDays: 182, usedDays: 0, iconName: 'pregnant_woman_rounded', colorValue: 0xFF7C3AED),
    const LeavePolicy(id: 'PL', title: 'Paternity Leave', description: 'Granted to male employees around spouse delivery.', totalDays: 15, usedDays: 0, iconName: 'child_care_rounded', colorValue: 0xFF0EA5E9),
    const LeavePolicy(id: 'CO', title: 'Compensatory Leave', description: 'Credit for working on holidays or weekly off days.', totalDays: 0, usedDays: 0, iconName: 'celebration_rounded', colorValue: 0xFFF59E0B),
  ];

  List<LeaveRequest> get requests => _filtered;
  List<LeaveRequest> get allRequests => _all;
  List<CompOffCredit> get compOffReports => _compOffReports;
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;
  List<LeavePolicy> get policies => _policies;

  Future<void> addCompOffReport(CompOffCredit report) async {
    _compOffReports.insert(0, report);
    notifyListeners();
    await _saveCompOffReports();
  }

  Future<void> approveCompOffReport(String id) async {
    final idx = _compOffReports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _compOffReports[idx] = _compOffReports[idx].copyWith(status: 'approved');
      notifyListeners();
      await _saveCompOffReports();
    }
  }

  Future<void> rejectCompOffReport(String id) async {
    final idx = _compOffReports.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _compOffReports[idx] = _compOffReports[idx].copyWith(status: 'rejected');
      notifyListeners();
      await _saveCompOffReports();
    }
  }

  Future<void> updatePolicy(String id, int newTotal) async {
    final idx = _policies.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _policies[idx] = _policies[idx].copyWith(totalDays: newTotal);
      _policies = List.from(_policies);
      notifyListeners();
      await _savePolicies();
    }
  }

  int get pendingCount {
    int leavePending = _all.where((r) => r.status == 'pending').length;
    int reportPending = _compOffReports.where((r) => r.status == 'pending').length;
    return leavePending + reportPending;
  }
  
  int get approvedCount => _all.where((r) => r.status == 'approved').length;
  int get rejectedCount => _all.where((r) => r.status == 'rejected').length;
  int get totalCount => _all.length + _compOffReports.length;

  LeaveProvider() {
    _loadFromPrefs().then((_) => loadLeaves());
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Policies
      final String? policiesJson = prefs.getString('leave_policies');
      if (policiesJson != null) {
        final List<dynamic> decoded = jsonDecode(policiesJson);
        _policies = decoded.map((item) => LeavePolicy(
          id: item['id'],
          title: item['title'],
          description: item['description'],
          totalDays: item['totalDays'],
          usedDays: item['usedDays'],
          iconName: item['iconName'],
          colorValue: item['colorValue'],
        )).toList();
      }

      // Load Requests
      final String? requestsJson = prefs.getString('leave_requests');
      if (requestsJson != null) {
        final List<dynamic> decoded = jsonDecode(requestsJson);
        _all = decoded.map((item) => LeaveRequest(
          id: item['id'],
          employeeId: item['employeeId'],
          employeeName: item['employeeName'],
          department: item['department'],
          leaveType: item['leaveType'],
          fromDate: item['fromDate'],
          toDate: item['toDate'],
          days: item['days'].toDouble(),
          reason: item['reason'],
          status: item['status'],
          appliedOn: item['appliedOn'],
          approvedBy: item['approvedBy'],
          remarks: item['remarks'],
        )).toList();
      }

      // Load CompOff Reports
      final String? compOffJson = prefs.getString('compoff_reports');
      if (compOffJson != null) {
        final List<dynamic> decoded = jsonDecode(compOffJson);
        _compOffReports = decoded.map((item) => CompOffCredit(
          id: item['id'],
          employeeId: item['employeeId'],
          employeeName: item['employeeName'],
          dutyDate: item['dutyDate'],
          expiryDate: item['expiryDate'],
          reason: item['reason'],
          status: item['status'],
          attachment: item['attachment'],
          duration: item['duration'],
        )).toList();
      }

      _applyFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _savePolicies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_policies.map((p) => {
        'id': p.id,
        'title': p.title,
        'description': p.description,
        'totalDays': p.totalDays,
        'usedDays': p.usedDays,
        'iconName': p.iconName,
        'colorValue': p.colorValue,
      }).toList());
      await prefs.setString('leave_policies', encoded);
    } catch (e) {
      debugPrint('Error saving policies: $e');
    }
  }

  Future<void> _saveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_all.map((r) => {
        'id': r.id,
        'employeeId': r.employeeId,
        'employeeName': r.employeeName,
        'department': r.department,
        'leaveType': r.leaveType,
        'fromDate': r.fromDate,
        'toDate': r.toDate,
        'days': r.days,
        'reason': r.reason,
        'status': r.status,
        'appliedOn': r.appliedOn,
        'approvedBy': r.approvedBy,
        'remarks': r.remarks,
      }).toList());
      await prefs.setString('leave_requests', encoded);
    } catch (e) {
      debugPrint('Error saving requests: $e');
    }
  }

  Future<void> _saveCompOffReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_compOffReports.map((r) => {
        'id': r.id,
        'employeeId': r.employeeId,
        'employeeName': r.employeeName,
        'dutyDate': r.dutyDate,
        'expiryDate': r.expiryDate,
        'reason': r.reason,
        'status': r.status,
        'attachment': r.attachment,
        'duration': r.duration,
      }).toList());
      await prefs.setString('compoff_reports', encoded);
    } catch (e) {
      debugPrint('Error saving reports: $e');
    }
  }

  Future<void> addLeaveRequest(LeaveRequest request) async {
    _all.insert(0, request);
    _applyFilter();
    notifyListeners();
    await _saveRequests();
  }

  Future<void> loadLeaves() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    if (_all.isEmpty) {
      _all = List.from(LeaveMockData.requests);
      _applyFilter();
    }
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

  Future<void> approveLeave(String id) async {
    final idx = _all.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _all[idx] = LeaveRequest(
        id: _all[idx].id, employeeId: _all[idx].employeeId,
        employeeName: _all[idx].employeeName, department: _all[idx].department,
        leaveType: _all[idx].leaveType, fromDate: _all[idx].fromDate,
        toDate: _all[idx].toDate, days: _all[idx].days, reason: _all[idx].reason,
        status: 'approved', appliedOn: _all[idx].appliedOn, approvedBy: 'Admin',
      );
      _applyFilter();
      notifyListeners();
      await _saveRequests();
    }
  }

  Future<void> rejectLeave(String id) async {
    final idx = _all.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _all[idx] = LeaveRequest(
        id: _all[idx].id, employeeId: _all[idx].employeeId,
        employeeName: _all[idx].employeeName, department: _all[idx].department,
        leaveType: _all[idx].leaveType, fromDate: _all[idx].fromDate,
        toDate: _all[idx].toDate, days: _all[idx].days, reason: _all[idx].reason,
        status: 'rejected', appliedOn: _all[idx].appliedOn, approvedBy: 'Admin',
      );
      _applyFilter();
      notifyListeners();
      await _saveRequests();
    }
  }
}
