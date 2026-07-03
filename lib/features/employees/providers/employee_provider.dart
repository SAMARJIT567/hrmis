// ============================================================
// 📁 lib/features/employees/providers/employee_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages employee list, search, and filter state.
// ============================================================

import 'package:flutter/material.dart';
import '../models/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _allEmployees = [];
  List<Employee> _filteredList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedStatus = 'All';

  List<Employee> get employees => _filteredList;
  List<Employee> get allEmployees => _allEmployees;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedDept => _selectedDept;
  String get selectedStatus => _selectedStatus;
  int get totalCount => _allEmployees.length;
  int get activeCount => _allEmployees.where((e) => e.isActive).length;
  int get inactiveCount => _allEmployees.where((e) => !e.isActive).length;

  List<String> get departments {
    final depts = _allEmployees.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...depts];
  }

  Map<String, int> get departmentCounts {
    final Map<String, int> counts = {};
    for (final e in _allEmployees) {
      counts[e.department] = (counts[e.department] ?? 0) + 1;
    }
    return counts;
  }

  EmployeeProvider() {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _allEmployees = List.from(EmployeeMockData.employees);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByDepartment(String dept) {
    _selectedDept = dept;
    _applyFilters();
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedDept = 'All';
    _selectedStatus = 'All';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredList = _allEmployees.where((emp) {
      final query = _searchQuery.toLowerCase();
      final matchSearch = query.isEmpty ||
          emp.name.toLowerCase().contains(query) ||
          emp.id.toLowerCase().contains(query) ||
          emp.email.toLowerCase().contains(query) ||
          emp.designation.toLowerCase().contains(query);

      final matchDept = _selectedDept == 'All' ||
          emp.department == _selectedDept;

      final matchStatus = _selectedStatus == 'All' ||
          emp.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchSearch && matchDept && matchStatus;
    }).toList();

    notifyListeners();
  }

  void addEmployee(Employee emp) {
    _allEmployees.add(emp);
    _applyFilters();
  }

  void updateEmployee(Employee updated) {
    final idx = _allEmployees.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _allEmployees[idx] = updated;
      _applyFilters();
    }
  }

  Employee? getById(String id) {
    try {
      return _allEmployees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}