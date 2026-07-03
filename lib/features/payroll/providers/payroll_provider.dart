// ============================================================
// 📁 lib/features/payroll/providers/payroll_provider.dart
// ─────────────────────────────────────────────────────────────
// Payroll state management.
// ============================================================

import 'package:flutter/material.dart';
import '../models/payroll_model.dart';

class PayrollProvider extends ChangeNotifier {
  List<PayrollRecord> _all = [];
  List<PayrollRecord> _filtered = [];
  bool _loading = false;
  String _filter = 'All';

  List<PayrollRecord> get records => _filtered;
  bool get isLoading => _loading;
  String get filter => _filter;

  int get paidCount => _all.where((r) => r.status == 'paid').length;
  int get pendingCount => _all.where((r) => r.status == 'pending').length;
  double get totalNetPayroll => _all.fold(0, (sum, r) => sum + r.netSalary);

  PayrollProvider() { loadPayroll(); }

  Future<void> loadPayroll() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _all = List.from(PayrollMockData.records);
    _applyFilter();
    _loading = false;
    notifyListeners();
  }

  void filterBy(String status) {
    _filter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filtered = _filter == 'All'
        ? List.from(_all)
        : _all.where((r) => r.status == _filter.toLowerCase()).toList();
    notifyListeners();
  }
}