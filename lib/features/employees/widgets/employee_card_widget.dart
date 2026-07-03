// ============================================================
// 📁 lib/features/employees/widgets/employee_card_widget.dart
// ─────────────────────────────────────────────────────────────
// Reusable employee card used in the employees list screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/employee_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  final Color? cardColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets margin;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    this.cardColor,
    this.borderColor,
    this.borderRadius = 14,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 14.w),
                Expanded(child: _buildInfo()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(),
                    SizedBox(height: 8.h),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = AppHelpers.getInitials(employee.name);
    final avatarBg = AppHelpers.getAvatarColor(employee.name);
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: avatarBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.name,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          employee.designation,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppHelpers.getDepartmentIcon(employee.department),
                size: 11.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.w),
              Text(
                employee.department,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = employee.isActive;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}