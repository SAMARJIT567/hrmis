// ============================================================
// features/dashboard/widgets/recent_activity_widget.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

const List<ActivityItem> mockActivities = [
  ActivityItem(
    title: 'Leave Approved',
    subtitle: 'Priya Sharma — Annual Leave (3 days)',
    time: '2 min ago',
    icon: Icons.event_available,
    iconColor: AppColors.success,
    iconBg: AppColors.successLight,
  ),
  ActivityItem(
    title: 'New Employee Added',
    subtitle: 'Rajesh Kumar joined as Backend Developer',
    time: '1 hr ago',
    icon: Icons.person_add,
    iconColor: AppColors.primary,
    iconBg: AppColors.primarySurface,
  ),
  ActivityItem(
    title: 'Payroll Processed',
    subtitle: 'April 2024 payroll — ₹4,85,000 disbursed',
    time: '3 hr ago',
    icon: Icons.account_balance_wallet,
    iconColor: AppColors.secondary,
    iconBg: AppColors.secondaryLight,
  ),
  ActivityItem(
    title: 'Late Check-in',
    subtitle: 'Amit Patel marked late (09:47 AM)',
    time: 'Yesterday',
    icon: Icons.access_time,
    iconColor: AppColors.warning,
    iconBg: AppColors.warningLight,
  ),
  ActivityItem(
    title: 'Leave Request',
    subtitle: 'Neha Singh requested sick leave',
    time: 'Yesterday',
    icon: Icons.sick,
    iconColor: AppColors.error,
    iconBg: AppColors.errorLight,
  ),
];

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(mockActivities.length, (i) {
          return _ActivityTile(
            item: mockActivities[i],
            isLast: i == mockActivities.length - 1,
          );
        }),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  final bool isLast;

  const _ActivityTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(item.icon, size: 20.sp, color: item.iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            item.time,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}