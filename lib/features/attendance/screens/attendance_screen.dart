// ============================================================
// 📁 lib/features/attendance/screens/attendance_screen.dart
// ─────────────────────────────────────────────────────────────
// Daily attendance tracking and management screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSummaryCards(),
                  _buildFilterTabs(),
                  _buildAttendanceList(),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final today = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 24.h),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      today,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
              _headerBtn(Icons.calendar_month_rounded),
              SizedBox(width: 10.w),
              _headerBtn(Icons.download_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon) => Container(
    width: 38.w,
    height: 38.h,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Icon(icon, color: Colors.white, size: 19.sp),
  );

  Widget _buildSummaryCards() {
    return Consumer<AttendanceProvider>(
      builder: (_, prov, __) {
        return Container(
          margin: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Expanded(child: _summaryCard('Present', prov.presentCount,
                  AppColors.success, AppColors.successLight, Icons.check_circle_outline)),
              SizedBox(width: 10.w),
              Expanded(child: _summaryCard('Absent', prov.absentCount,
                  AppColors.error, AppColors.errorLight, Icons.cancel_outlined)),
              SizedBox(width: 10.w),
              Expanded(child: _summaryCard('Late', prov.lateCount,
                  AppColors.warning, AppColors.warningLight, Icons.access_time_rounded)),
              SizedBox(width: 10.w),
              Expanded(child: _summaryCard('Leave', prov.leaveCount,
                  AppColors.secondary, AppColors.secondaryLight, Icons.event_busy_rounded)),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, int count, Color color, Color bg, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, color: color, size: 17.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'present', 'absent', 'late', 'leave'];
    return Consumer<AttendanceProvider>(
      builder: (_, prov, __) {
        return Container(
          height: 44.h,
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: filters.length,
            itemBuilder: (_, i) {
              final f = filters[i];
              final isSelected = prov.filterStatus == f;
              final label = f == 'All' ? 'All'
                  : f[0].toUpperCase() + f.substring(1);
              return GestureDetector(
                onTap: () => prov.filterByStatus(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppHelpers.getAttendanceColor(f == 'All' ? 'present' : f)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? AppHelpers.getAttendanceColor(f == 'All' ? 'present' : f)
                          : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    return Consumer<AttendanceProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading) return Padding(
          padding: EdgeInsets.all(32.r),
          child: const InlineLoader(),
        );

        if (prov.records.isEmpty) return EmptyStateWidget(
          icon: Icons.event_busy_rounded,
          title: 'No Records Found',
          subtitle: 'No attendance records for this filter.',
        );

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: prov.records.length,
          itemBuilder: (_, i) => _AttendanceCard(record: prov.records[i]),
        );
      },
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getAttendanceColor(record.status);
    final initials = AppHelpers.getInitials(record.employeeName);
    final avatarBg = AppHelpers.getAvatarColor(record.employeeName);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: avatarBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.employeeName,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    record.department,
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (record.checkIn != null) ...[
                        Icon(Icons.login_rounded, size: 11.sp, color: AppColors.success),
                        SizedBox(width: 3.w),
                        Text(
                          record.checkIn!,
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.success),
                        ),
                        SizedBox(width: 10.w),
                      ],
                      if (record.checkOut != null) ...[
                        Icon(Icons.logout_rounded, size: 11.sp, color: AppColors.error),
                        SizedBox(width: 3.w),
                        Text(
                          record.checkOut!,
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.error),
                        ),
                      ],
                      if (record.remarks != null)
                        Text(
                          record.remarks!,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    record.status[0].toUpperCase() + record.status.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (record.workHours != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    record.workHours!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}