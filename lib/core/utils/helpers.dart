// ============================================================
// 📁 lib/core/utils/helpers.dart
// ─────────────────────────────────────────────────────────────
// Utility functions and helpers used across the app.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AppHelpers {
  AppHelpers._();

  // ─── Date Formatters ──────────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // ─── Greeting based on time of day ────────────────────────────
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  // ─── Avatar Initials ──────────────────────────────────────────
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  // ─── Avatar Background Color ──────────────────────────────────
  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFF1E40AF),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF0891B2),
      const Color(0xFF65A30D),
      const Color(0xFFDB2777),
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  // ─── Leave Status Color ───────────────────────────────────────
  static Color getLeaveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.leaveApproved;
      case 'rejected':
        return AppColors.leaveRejected;
      default:
        return AppColors.leavePending;
    }
  }

  static Color getLeaveStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.successLight;
      case 'rejected':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  // ─── Attendance Status Color ──────────────────────────────────
  static Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.attendancePresent;
      case 'absent':
        return AppColors.attendanceAbsent;
      case 'late':
        return AppColors.attendanceLate;
      case 'leave':
        return AppColors.attendanceLeave;
      default:
        return AppColors.textSecondary;
    }
  }

  // ─── SnackBar helpers ─────────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Department Icon ──────────────────────────────────────────
  static IconData getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'engineering':
        return Icons.code_rounded;
      case 'design':
        return Icons.design_services_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'finance':
        return Icons.account_balance_rounded;
      case 'hr':
        return Icons.people_rounded;
      case 'sales':
        return Icons.trending_up_rounded;
      case 'operations':
        return Icons.settings_rounded;
      case 'legal':
        return Icons.gavel_rounded;
      default:
        return Icons.business_rounded;
    }
  }
}