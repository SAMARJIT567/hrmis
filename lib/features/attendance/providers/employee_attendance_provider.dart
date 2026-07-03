// ============================================================
// 📁 lib/features/attendance/providers/employee_attendance_provider.dart
// ============================================================
// Provider for managing individual employee attendance state
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeAttendanceRecord {
  final String id;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? workHours;
  final String? lateDuration;

  const EmployeeAttendanceRecord({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workHours,
    this.lateDuration,
  });
}

class EmployeeAttendanceProvider extends ChangeNotifier {
  List<EmployeeAttendanceRecord> _records = [];
  bool _isLoading = false;
  bool _isCheckedIn = false;
  String? _currentCheckInTime;
  String? _currentLateDuration;

  List<EmployeeAttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  bool get isCheckedIn => _isCheckedIn;
  String? get currentCheckInTime => _currentCheckInTime;
  String? get currentLateDuration => _currentLateDuration;

  int get presentCount => _records.where((r) => r.status == 'Present').length;
  int get absentCount => _records.where((r) => r.status == 'Absent').length;
  int get lateCount => _records.where((r) => r.status == 'Late').length;

  EmployeeAttendanceProvider() {
    loadMyAttendance();
  }

  Future<void> loadMyAttendance() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    _records = [
      const EmployeeAttendanceRecord(id: '1', date: '20 May 2025', checkIn: '09:05 AM', checkOut: '06:10 PM', status: 'Present', workHours: '9h 5m', lateDuration: null),
      const EmployeeAttendanceRecord(id: '2', date: '19 May 2025', checkIn: '09:00 AM', checkOut: '06:00 PM', status: 'Present', workHours: '9h 0m', lateDuration: null),
      const EmployeeAttendanceRecord(id: '3', date: '18 May 2025', checkIn: '09:45 AM', checkOut: '06:15 PM', status: 'Late', workHours: '8h 30m', lateDuration: '15 minutes'),
      const EmployeeAttendanceRecord(id: '4', date: '17 May 2025', checkIn: null, checkOut: null, status: 'Absent', workHours: null, lateDuration: null),
      const EmployeeAttendanceRecord(id: '5', date: '16 May 2025', checkIn: '10:30 AM', checkOut: '06:05 PM', status: 'Late', workHours: '7h 35m', lateDuration: '30 minutes'),
    ];

    _checkTodayAttendance();
    _isLoading = false;
    notifyListeners();
  }

  void _checkTodayAttendance() {
    final today = DateFormat('dd MMM yyyy').format(DateTime.now());
    final index = _records.indexWhere((r) => r.date == today);
    if (index != -1) {
      final todayRecord = _records[index];
      _isCheckedIn = todayRecord.checkIn != null && todayRecord.checkOut == null;
      _currentCheckInTime = todayRecord.checkIn;
      _currentLateDuration = todayRecord.lateDuration;
    } else {
      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentLateDuration = null;
    }
  }

  String _calculateLateDuration(DateTime checkInTime) {
    final expectedTime = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 10, 0);
    if (checkInTime.isAfter(expectedTime)) {
      final difference = checkInTime.difference(expectedTime);
      final minutes = difference.inMinutes;
      if (minutes < 60) return '$minutes minutes';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins minutes' : ''}';
    }
    return '';
  }

  Future<bool> checkIn() async {
    if (_isCheckedIn) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final checkInTime = DateFormat('hh:mm a').format(now);
    final today = DateFormat('dd MMM yyyy').format(now);
    final isLate = now.hour >= 10;
    final lateDuration = isLate ? _calculateLateDuration(now) : '';

    _records.insert(0, EmployeeAttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: today,
      checkIn: checkInTime,
      checkOut: null,
      status: isLate ? 'Late' : 'Present',
      workHours: null,
      lateDuration: isLate ? lateDuration : null,
    ));

    _isCheckedIn = true;
    _currentCheckInTime = checkInTime;
    _currentLateDuration = isLate ? lateDuration : null;
    notifyListeners();
    return true;
  }

  Future<bool> checkOut() async {
    if (!_isCheckedIn) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final checkOutTime = DateFormat('hh:mm a').format(now);
    final today = DateFormat('dd MMM yyyy').format(now);

    final index = _records.indexWhere((r) => r.date == today);
    if (index != -1) {
      final record = _records[index];
      try {
        final checkInDt = DateFormat('hh:mm a').parse(record.checkIn!);
        final checkInFull = DateTime(now.year, now.month, now.day, checkInDt.hour, checkInDt.minute);
        final workDuration = now.difference(checkInFull);
        final hours = workDuration.inHours;
        final minutes = workDuration.inMinutes % 60;

        _records[index] = EmployeeAttendanceRecord(
          id: record.id,
          date: record.date,
          checkIn: record.checkIn,
          checkOut: checkOutTime,
          status: record.status,
          workHours: '$hours h ${minutes}m',
          lateDuration: record.lateDuration,
        );
      } catch (e) {
        // Fallback if parsing fails
        _records[index] = EmployeeAttendanceRecord(
          id: record.id,
          date: record.date,
          checkIn: record.checkIn,
          checkOut: checkOutTime,
          status: record.status,
          workHours: '8h 0m',
          lateDuration: record.lateDuration,
        );
      }
    }

    _isCheckedIn = false;
    _currentCheckInTime = null;
    _currentLateDuration = null;
    notifyListeners();
    return true;
  }
}
