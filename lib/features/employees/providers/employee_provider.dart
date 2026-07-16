// ============================================================
// 📁 lib/features/employees/providers/employee_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages employee list, search, and filter state.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/employee_model.dart';
import '../../../core/services/api_service.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _allEmployees = [];
  List<Employee> _filteredList = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedStatus = 'All';

  // ─── Pagination ──────────────────────────────────────────────
  int _visibleCount = 15;
  bool get hasMore => _visibleCount < _filteredList.length;

  List<Employee> get employees => _filteredList.take(_visibleCount).toList();
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

  final ApiService _apiService = ApiService();

  Future<void> loadEmployees() async {
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
      _allEmployees = List.from(EmployeeMockData.employees);
    } else {
      try {
        final response = await _apiService.getEmployees();
        if (response['status'] == 'success' && response['data'] != null) {
          final List<dynamic> data = response['data'];
          _allEmployees = data.map((json) => Employee.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          _allEmployees = List.from(EmployeeMockData.employees);
        }
      } catch (e) {
        debugPrint('❌ Error loading employees, falling back to mock data: $e');
        _allEmployees = List.from(EmployeeMockData.employees);
      }
    }

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

  void loadMore() {
    _visibleCount += 5;
    notifyListeners();
  }

  void _applyFilters() {
    _visibleCount = 15; // Reset pagination when filters change
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
    _allEmployees.insert(0, emp);
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