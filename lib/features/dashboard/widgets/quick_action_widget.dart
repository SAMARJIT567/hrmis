// ============================================================
// features/dashboard/widgets/quick_action_widget.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.bgColor = const Color(0xFFEFF6FF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 26.sp, color: iconColor),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static const List<_ActionData> _actions = [
    _ActionData('Add Employee', Icons.person_add_alt_1, AppColors.primary, Color(0xFFEFF6FF)),
    _ActionData('Attendance', Icons.how_to_reg, AppColors.success, Color(0xFFECFDF5)),
    _ActionData('Apply Leave', Icons.event_available, AppColors.warning, Color(0xFFFFFBEB)),
    _ActionData('Run Payroll', Icons.account_balance, AppColors.secondary, Color(0xFFF5F3FF)),
    _ActionData('Reports', Icons.bar_chart, AppColors.info, Color(0xFFCFFAFE)),
    _ActionData('Settings', Icons.settings_outlined, AppColors.textTertiary, Color(0xFFF8FAFC)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMD.r),
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
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.9,
        children: _actions.map((a) {
          return QuickActionButton(
            label: a.label,
            icon: a.icon,
            iconColor: a.color,
            bgColor: a.bgColor,
            onTap: () {},
          );
        }).toList(),
      ),
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _ActionData(this.label, this.icon, this.color, this.bgColor);
}