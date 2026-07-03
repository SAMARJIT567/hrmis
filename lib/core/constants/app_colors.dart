// ============================================================
// 📁 lib/core/constants/app_colors.dart
// ─────────────────────────────────────────────────────────────
// All color constants used throughout the HRMIS app.
// Change colors here and they will reflect everywhere.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand Colors ──────────────────────────────────────
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // ─── Secondary / Accent Colors ────────────────────────────────
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFEDE9FE);
  static const Color accent = Color(0xFF0EA5E9);

  // ─── Background Colors ────────────────────────────────────────
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // ─── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFFCFFAFE);

  // ─── Border & Divider Colors ──────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF3B82F6);

  // ─── Shadow / Overlay ─────────────────────────────────────────
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // ─── Gradient Presets ─────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Convenience Aliases ────────────────────────────────
  static const Color shadowColor = Color(0x1A000000);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textHint = Color(0xFF94A3B8);

  // ─── Bottom Navigation Colors ─────────────────────────────────
  static const Color navSelected = Color(0xFF1E40AF);
  static const Color navUnselected = Color(0xFF94A3B8);
  static const Color navBackground = Color(0xFFFFFFFF);

  // ─── Specific Feature Colors ──────────────────────────────────
  static const Color attendancePresent = Color(0xFF10B981);
  static const Color attendanceAbsent = Color(0xFFEF4444);
  static const Color attendanceLate = Color(0xFFF59E0B);
  static const Color attendanceLeave = Color(0xFF8B5CF6);

  static const Color leaveApproved = Color(0xFF10B981);
  static const Color leavePending = Color(0xFFF59E0B);
  static const Color leaveRejected = Color(0xFFEF4444);

  static const Color payrollPaid = Color(0xFF10B981);
  static const Color payrollPending = Color(0xFFF59E0B);
}