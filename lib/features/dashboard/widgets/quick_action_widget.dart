// ============================================================
// features/dashboard/widgets/quick_action_widget.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/screens/office_settings_screen.dart';
import '../../employees/screens/add_employee_screen.dart';
import '../../attendance/screens/attendance_screen.dart';
import '../../leave/screens/leave_screen.dart';
import '../../leave/screens/leave_balance_screen.dart';

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
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22.sp, color: iconColor),
          ),
          SizedBox(height: 2.h),
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
    _ActionData('Leave Balance', Icons.account_balance_wallet_outlined, AppColors.secondary, Color(0xFFF5F3FF)),
    _ActionData('Settings', Icons.settings_outlined, AppColors.textTertiary, Color(0xFFF8FAFC)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 1.1,
        children: _actions.map((a) {
          return QuickActionButton(
            label: a.label,
            icon: a.icon,
            iconColor: a.color,
            bgColor: a.bgColor,
            onTap: () {
              final navProv = context.read<NavigationProvider>();
              final isAdmin = context.read<AuthProvider>().isAdmin;

              if (a.label == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfficeSettingsScreen(),
                  ),
                );
              } else if (a.label == 'Add Employee') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEmployeeScreen(),
                  ),
                );
              } else if (a.label == 'Attendance') {
                if (isAdmin) {
                  navProv.setIndex(2); // Attendance Tab
                } else {
                  navProv.setIndex(0); // Employee Dashboard has Attendance
                }
              } else if (a.label == 'Apply Leave') {
                if (isAdmin) {
                  navProv.setIndex(3); // Leave Tab
                } else {
                  navProv.setIndex(2); // Employee Leave Tab
                }
              } else if (a.label == 'Leave Balance') {
                Navigator.pushNamed(context, '/leave-balance');
              }
            },
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