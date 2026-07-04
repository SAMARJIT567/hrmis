// ============================================================
// 📁 lib/features/attendance/screens/attendance_calendar_screen.dart
// ============================================================
// Calendar Screen - NO BOTTOM NAVIGATION (Parent se milega)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final Map<String, String> _attendanceData = {
    '2026-05-01': 'Present', '2026-05-02': 'Present', '2026-05-03': 'Absent',
    '2026-05-04': 'Present', '2026-05-05': 'Leave', '2026-05-06': 'Present',
    '2026-05-07': 'Holiday', '2026-05-08': 'Present', '2026-05-09': 'Present',
    '2026-05-10': 'Late', '2026-05-11': 'Present', '2026-05-12': 'Absent',
    '2026-05-13': 'Present', '2026-05-14': 'Present', '2026-05-15': 'Leave',
    '2026-05-16': 'Present', '2026-05-17': 'Holiday', '2026-05-18': 'Present',
    '2026-05-19': 'Present', '2026-05-20': 'Present', '2026-05-21': 'Late',
    '2026-05-22': 'Present', '2026-05-23': 'Present', '2026-05-24': 'Absent',
    '2026-05-25': 'Present', '2026-05-26': 'Present',
  };

  String? getStatusForDate(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isAfter(todayDate)) return null;
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _attendanceData[key] ?? 'Present';
  }

  Color getStatusColor(String? status) {
    if (status == null) return AppColors.border;
    switch (status) {
      case 'Present': return AppColors.success;
      case 'Absent': return AppColors.error;
      case 'Leave': return AppColors.secondary;
      case 'Holiday': return AppColors.info;
      case 'Late': return AppColors.warning;
      default: return AppColors.textTertiary;
    }
  }

  String getStatusIcon(String? status) {
    if (status == null) return '-';
    switch (status) {
      case 'Present': return '✓';
      case 'Absent': return '✗';
      case 'Leave': return '🌴';
      case 'Holiday': return '🎉';
      case 'Late': return '⏰';
      default: return '•';
    }
  }

  String getStatusDisplay(String? status) {
    if (status == null) return 'No Record';
    return status;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Attendance Calendar',
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [_buildMonthSelector()],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildLegend(),
            _buildCalendar(),
            _buildSummaryCards(),
            _buildSelectedDateInfo(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: _previousMonth,
            iconSize: 24.sp,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: _nextMonth,
            iconSize: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final legendItems = [
      {'status': 'Present', 'color': AppColors.success},
      {'status': 'Absent', 'color': AppColors.error},
      {'status': 'Leave', 'color': AppColors.secondary},
      {'status': 'Holiday', 'color': AppColors.info},
      {'status': 'Late', 'color': AppColors.warning},
      {'status': 'No Record', 'color': AppColors.border},
    ];

    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.w,
        runSpacing: 4.h,
        children: legendItems.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w, height: 8.h,
                decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
              ),
              SizedBox(width: 3.w),
              Text(
                item['status'] as String,
                style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textSecondary),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    int startOffset = firstWeekday - 1;
    if (startOffset == 0) startOffset = 7;
    startOffset = startOffset - 1;

    final totalDays = startOffset + daysInMonth;
    final numRows = (totalDays / 7).ceil();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                return Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                );
              }).toList(),
            ),
          ),
          ...List.generate(numRows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final dayIndex = row * 7 + col - startOffset;
                if (dayIndex >= 0 && dayIndex < daysInMonth) {
                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayIndex + 1);
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final status = getStatusForDate(date);
                  final statusColor = getStatusColor(status);
                  final isSelected = _selectedDate.year == date.year &&
                      _selectedDate.month == date.month &&
                      _selectedDate.day == date.day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        margin: EdgeInsets.all(2.r),
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? statusColor.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          border: isSelected
                              ? Border.all(color: statusColor, width: 1)
                              : (isToday ? Border.all(color: AppColors.primary, width: 1) : null),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${dayIndex + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: isToday ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              width: 20.w, height: 20.h,
                              decoration: BoxDecoration(
                                color: status == null ? AppColors.border.withOpacity(0.3) : statusColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  getStatusIcon(status),
                                  style: TextStyle(fontSize: 10.sp, color: status == null ? AppColors.textTertiary : Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Expanded(child: Container());
                }
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int present = 0, absent = 0, leave = 0, holiday = 0, late = 0;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, i);
      final checkDate = DateTime(date.year, date.month, date.day);

      if (checkDate.isAfter(todayDate)) continue;

      final status = getStatusForDate(date);
      if (status == null) continue;

      switch (status) {
        case 'Present': present++; break;
        case 'Absent': absent++; break;
        case 'Leave': leave++; break;
        case 'Holiday': holiday++; break;
        case 'Late': late++; break;
      }
    }

    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _summaryCard('Present', present, AppColors.success, Icons.check_circle),
              SizedBox(width: 6.w),
              _summaryCard('Absent', absent, AppColors.error, Icons.cancel),
              SizedBox(width: 6.w),
              _summaryCard('Leave', leave, AppColors.secondary, Icons.beach_access),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              _summaryCard('Holiday', holiday, AppColors.info, Icons.celebration),
              SizedBox(width: 6.w),
              _summaryCard('Late', late, AppColors.warning, Icons.access_time),
              SizedBox(width: 6.w),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(height: 2.h),
            Text('$count', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final status = getStatusForDate(_selectedDate);
    final statusColor = getStatusColor(status);
    final isFutureDate = _selectedDate.isAfter(DateTime.now());

    return Container(
      margin: EdgeInsets.fromLTRB(12.r, 0, 12.r, 16.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: isFutureDate ? null : AppColors.primaryGradient,
        color: isFutureDate ? AppColors.surfaceVariant : null,
        borderRadius: BorderRadius.circular(12.r),
        border: isFutureDate ? Border.all(color: AppColors.border) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
            child: Center(
              child: Text('${_selectedDate.day}', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: isFutureDate ? AppColors.textSecondary : Colors.white70),
                ),
                Text(
                  isFutureDate ? 'Future Date - No Record' : 'Status: ${getStatusDisplay(status)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isFutureDate ? AppColors.textSecondary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32.w, height: 32.h,
            decoration: BoxDecoration(
              color: isFutureDate ? AppColors.border : statusColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                getStatusIcon(isFutureDate ? null : status),
                style: TextStyle(fontSize: 16.sp, color: isFutureDate ? AppColors.textTertiary : Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}