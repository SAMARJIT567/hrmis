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
      builder: (context, prov, __) {
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
          itemBuilder: (context, i) => _AttendanceCard(
            record: prov.records[i],
            onTap: () => _showEmployeeDetails(context, prov.records[i]),
          ),
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmployeeDetailsSheet(record: record),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback onTap;
  const _AttendanceCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getAttendanceColor(record.status);
    final initials = AppHelpers.getInitials(record.employeeName);
    final avatarBg = AppHelpers.getAvatarColor(record.employeeName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _EmployeeDetailsSheet extends StatelessWidget {
  final AttendanceRecord record;
  const _EmployeeDetailsSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  image: record.employeeImage != null
                      ? DecorationImage(
                          image: NetworkImage(record.employeeImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppHelpers.getAvatarColor(record.employeeName),
                ),
                child: record.employeeImage == null
                    ? Center(
                        child: Text(
                          AppHelpers.getInitials(record.employeeName),
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${record.department} • ${record.employeeId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppHelpers.getAttendanceColor(record.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  record.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppHelpers.getAttendanceColor(record.status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Date',
            record.date == 'Today' ? DateFormat('dd MMM yyyy').format(DateTime.now()) : record.date,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  Icons.login_rounded,
                  'Check In',
                  record.checkIn ?? '--:--',
                  AppColors.success,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTimeInfo(
                  Icons.logout_rounded,
                  'Check Out',
                  record.checkOut ?? (record.checkIn != null ? 'Pending' : '--:--'),
                  record.checkOut != null ? AppColors.error : AppColors.warning,
                ),
              ),
            ],
          ),
          if (record.checkInSelfie != null) ...[
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Check-in Selfie',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(record.checkInSelfie!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          if (record.checkInLocation != null) ...[
            SizedBox(height: 20.h),
            _buildInfoRow(
              Icons.location_on_rounded,
              'Check-in Location',
              record.checkInLocation!,
            ),
            if (record.latitude != null && record.longitude != null)
              Padding(
                padding: EdgeInsets.only(left: 42.w, top: 4.h),
                child: Text(
                  'Lat: ${record.latitude}, Lng: ${record.longitude}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: Text(
                'Close Details',
                style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.textSecondary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeInfo(IconData icon, String label, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
