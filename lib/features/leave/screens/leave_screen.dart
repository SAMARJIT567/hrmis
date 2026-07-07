// ============================================================
// 📁 lib/features/leave/screens/leave_screen.dart
// ============================================================
// Admin Leave Management Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/leave_provider.dart';
import '../models/leave_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _buildSummaryStats(),
                _buildFilterTabs(),
                _buildRequestsList(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 20.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Management',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Review and approve requests',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          _headerBtn(Icons.notifications_outlined),
          SizedBox(width: 10.w),
          _headerBtn(Icons.filter_list_rounded),
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

  Widget _buildSummaryStats() {
    return Consumer<LeaveProvider>(
      builder: (_, prov, __) => Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _summaryItem('Total', prov.totalCount, AppColors.primary)),
            _divider(),
            Expanded(child: _summaryItem('Pending', prov.pendingCount, AppColors.warning)),
            _divider(),
            Expanded(child: _summaryItem('Approved', prov.approvedCount, AppColors.success)),
            _divider(),
            Expanded(child: _summaryItem('Rejected', prov.rejectedCount, AppColors.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Consumer<LeaveProvider>(
      builder: (_, prov, __) {
        final filters = ['All', 'pending', 'approved', 'rejected'];
        return SizedBox(
          height: 44.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: filters.length,
            itemBuilder: (_, i) {
              final f = filters[i];
              final isSelected = prov.currentFilter == f;
              final color = f == 'All'
                  ? AppColors.primary
                  : AppHelpers.getLeaveStatusColor(f);
              return GestureDetector(
                onTap: () => prov.filterBy(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  decoration: BoxDecoration(
                    color: isSelected ? color : AppColors.surface,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      f[0].toUpperCase() + f.substring(1),
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

  Widget _buildRequestsList() {
    return Consumer<LeaveProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading) {
          return Padding(
            padding: EdgeInsets.all(32.r),
            child: const InlineLoader(),
          );
        }
        
        final allItems = [
          ...prov.requests,
          ...prov.compOffReports.where((r) => prov.currentFilter == 'All' || r.status.toLowerCase() == prov.currentFilter.toLowerCase()),
        ];

        // Sort items: Pending first, then by ID (Timestamp) descending
        allItems.sort((a, b) {
          String statusA = (a is LeaveRequest) ? a.status : (a as CompOffCredit).status;
          String statusB = (b is LeaveRequest) ? b.status : (b as CompOffCredit).status;
          String idA = (a is LeaveRequest) ? a.id : (a as CompOffCredit).id;
          String idB = (b is LeaveRequest) ? b.id : (b as CompOffCredit).id;

          if (statusA == 'pending' && statusB != 'pending') return -1;
          if (statusA != 'pending' && statusB == 'pending') return 1;
          return idB.compareTo(idA); // Newer items first
        });

        if (allItems.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.event_busy_rounded,
            title: 'No Items Found',
            subtitle: 'No requests match this filter.',
          );
        }

        return Column(
          children: allItems.map((item) {
            if (item is LeaveRequest) {
              return _LeaveCard(
                request: item,
                onAction: () => _showRequestDetails(context, item, prov),
              );
            } else if (item is CompOffCredit) {
              return _CompOffReportCard(
                report: item,
                onAction: () => _showCompOffDetails(context, item, prov),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  void _showRequestDetails(BuildContext context, LeaveRequest request, LeaveProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LeaveDetailsSheet(
        request: request,
        onApprove: () {
          provider.approveLeave(request.id);
          Navigator.pop(context);
          AppHelpers.showSuccess(context, 'Leave approved!');
        },
        onReject: () {
          provider.rejectLeave(request.id);
          Navigator.pop(context);
          AppHelpers.showError(context, 'Leave rejected.');
        },
      ),
    );
  }

  void _showCompOffDetails(BuildContext context, CompOffCredit report, LeaveProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CompOffDetailsSheet(
        report: report,
        onApprove: () {
          provider.approveCompOffReport(report.id);
          Navigator.pop(context);
          AppHelpers.showSuccess(context, 'Duty report approved!');
        },
        onReject: () {
          provider.rejectCompOffReport(report.id);
          Navigator.pop(context);
          AppHelpers.showError(context, 'Duty report rejected.');
        },
      ),
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 36.h,
        width: 1,
        color: AppColors.border,
      );
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback onAction;

  const _LeaveCard({
    required this.request,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getLeaveStatusColor(request.status);
    final statusBg = AppHelpers.getLeaveStatusBgColor(request.status);
    final initials = AppHelpers.getInitials(request.employeeName);
    final avatarBg = AppHelpers.getAvatarColor(request.employeeName);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
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
                        request.employeeName,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${request.department} • ${request.leaveType}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    request.status[0].toUpperCase() + request.status.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(child: _detailItem(Icons.calendar_today_outlined, 'From', request.fromDate)),
                SizedBox(width: 12.w),
                Expanded(child: _detailItem(Icons.event_rounded, 'To', request.toDate)),
                SizedBox(width: 12.w),
                Expanded(child: _detailItem(Icons.timer_outlined, 'Days', '${request.days % 1 == 0 ? request.days.toInt() : request.days} Day${request.days > 1 ? 's' : ''}')),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(10.r),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.remove_red_eye_outlined, size: 16.sp),
                label: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 11.sp, color: AppColors.textTertiary),
          SizedBox(width: 3.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textTertiary)),
        ]),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LeaveDetailsSheet extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LeaveDetailsSheet({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getLeaveStatusColor(request.status);
    final statusBg = AppHelpers.getLeaveStatusBgColor(request.status);

    return Container(
      padding: EdgeInsets.fromLTRB(20.r, 12.h, 20.r, MediaQuery.of(context).padding.bottom + 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Leave Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _infoTile('Employee', request.employeeName, Icons.person_outline),
          _infoTile('Department', request.department, Icons.business_outlined),
          _infoTile('Leave Type', request.leaveType, Icons.event_note_outlined),
          Row(
            children: [
              Expanded(child: _infoTile('From', request.fromDate, Icons.calendar_today_outlined)),
              Expanded(child: _infoTile('To', request.toDate, Icons.event_available_outlined)),
            ],
          ),
          _infoTile('Duration', '${request.days} Days', Icons.timer_outlined),
          SizedBox(height: 12.h),
          Text(
            'Reason',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              request.reason,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          if (request.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorLight,
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Approve',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompOffReportCard extends StatelessWidget {
  final CompOffCredit report;
  final VoidCallback onAction;

  const _CompOffReportCard({
    required this.report,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getLeaveStatusColor(report.status);
    final statusBg = AppHelpers.getLeaveStatusBgColor(report.status);
    final initials = AppHelpers.getInitials(report.employeeName);
    final avatarBg = Colors.orange[400];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
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
                        report.employeeName,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Compensatory Leave (Duty Report)',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.orange.withOpacity(0.1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(child: _detailItem(Icons.calendar_month_rounded, 'Duty Date', report.dutyDate)),
                SizedBox(width: 12.w),
                Expanded(child: _detailItem(Icons.timer_outlined, 'Duration', report.duration ?? 'N/A')),
                SizedBox(width: 12.w),
                Expanded(child: _detailItem(Icons.verified_user_outlined, 'Valid Til', report.expiryDate)),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.orange.withOpacity(0.1)),
          Padding(
            padding: EdgeInsets.all(10.r),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.rate_review_outlined, size: 16.sp, color: Colors.orange[800]),
                label: Text(
                  'Review Duty Report',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.08),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 11.sp, color: AppColors.textTertiary),
          SizedBox(width: 3.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textTertiary)),
        ]),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CompOffDetailsSheet extends StatelessWidget {
  final CompOffCredit report;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _CompOffDetailsSheet({
    required this.report,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getLeaveStatusColor(report.status);
    final statusBg = AppHelpers.getLeaveStatusBgColor(report.status);

    return Container(
      padding: EdgeInsets.fromLTRB(20.r, 12.h, 20.r, MediaQuery.of(context).padding.bottom + 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Compensatory Leave Credit Request', 
                  style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20.r)),
                child: Text(report.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _infoTile('Employee', report.employeeName, Icons.person_outline),
          _infoTile('Duty Date', report.dutyDate, Icons.calendar_today_outlined),
          _infoTile('Duration', report.duration ?? 'N/A', Icons.timer_outlined),
          _infoTile('Expiry Date', report.expiryDate, Icons.event_available_outlined),
          SizedBox(height: 12.h),
          Text('Reason/Remarks', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity, padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
            child: Text(report.reason, style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textPrimary)),
          ),
          if (report.attachment.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 24.sp, color: AppColors.error),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Written Order Attachment',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
                        ),
                        Text(
                          report.attachment, 
                          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          AppHelpers.showError(context, 'Could not open PDF viewer');
                        }
                      }
                    },
                    icon: Icon(Icons.remove_red_eye_rounded, size: 16.sp),
                    label: Text('View', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 32.h),
          if (report.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorLight, foregroundColor: AppColors.error, elevation: 0, minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: AppColors.error.withOpacity(0.3))),
                    ),
                    child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 2, minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Approve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary)),
                Text(value, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
