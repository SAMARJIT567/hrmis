// ============================================================
// 📁 lib/features/leave/screens/leave_screen.dart
// ============================================================
// FULLY NON-STICKY - Everything scrolls freely
// Bottom navigation with Leave + Profile tabs
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../models/leave_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../profile/screens/profile_screen.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildLeaveManagementContent(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveManagementContent() {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, topPadding + 20.h, 20.w, 22.h),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
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
                SizedBox(height: 4.h),
                Text(
                  'Review and approve leave requests',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Consumer<LeaveProvider>(
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
          ),
          Consumer<LeaveProvider>(
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
          ),
          Consumer<LeaveProvider>(
            builder: (_, prov, __) {
              if (prov.isLoading) {
                return Padding(
                  padding: EdgeInsets.all(32.r),
                  child: const InlineLoader(),
                );
              }
              if (prov.requests.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.event_busy_rounded,
                  title: 'No Leave Requests',
                  subtitle: 'No requests match this filter.',
                );
              }
              return Column(
                children: prov.requests.map((request) => _LeaveCard(
                  request: request,
                  onApprove: () {
                    prov.approveLeave(request.id);
                    AppHelpers.showSuccess(context, 'Leave approved!');
                  },
                  onReject: () {
                    prov.rejectLeave(request.id);
                    AppHelpers.showError(context, 'Leave rejected.');
                  },
                )).toList(),
              );
            },
          ),
          SizedBox(height: 80.h),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded, size: 20.sp),
        label: Text(
          'Apply Leave',
          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
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
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LeaveCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
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
            child: Column(
              children: [
                Row(
                  children: [
                    _detailItem(Icons.calendar_today_outlined, 'From', request.fromDate),
                    SizedBox(width: 16.w),
                    _detailItem(Icons.event_rounded, 'To', request.toDate),
                    SizedBox(width: 16.w),
                    _detailItem(Icons.timer_outlined, 'Days', '${request.days} Day${request.days > 1 ? 's' : ''}'),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    request.reason,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (request.status == 'pending') ...[
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onReject,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Reject',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onApprove,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'Approve',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Row(
                children: [
                  Icon(Icons.person_outlined, size: 12.sp, color: AppColors.textTertiary),
                  SizedBox(width: 4.w),
                  Text(
                    request.approvedBy != null
                        ? 'By: ${request.approvedBy}  • ${request.appliedOn}'
                        : 'Applied on: ${request.appliedOn}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
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