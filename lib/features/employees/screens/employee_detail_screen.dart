// ============================================================
// features/employees/screens/employee_detail_screen.dart
// ============================================================
// Employee profile: gradient header, 3 stat cards,
// personal / work / contact info sections, payroll summary.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/employee_model.dart';
import '../providers/employee_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    final employee = context.read<EmployeeProvider>().getById(employeeId);

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined, size: 60.sp, color: AppColors.textHint),
              SizedBox(height: 16.h),
              Text(
                'Employee not found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildProfileHeader(context, employee),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
              child: Column(
                children: [
                  _buildStatsRow(employee),
                  SizedBox(height: 16.h),
                  _buildInfoSection('Personal Information', [
                    _infoRow(Icons.badge_outlined, 'Employee ID', employee.id),
                    _infoRow(Icons.person_outline, 'Full Name', employee.name),
                    _infoRow(Icons.wc_rounded, 'Gender', employee.gender),
                    _infoRow(Icons.location_on_outlined, 'Address', employee.address),
                  ]),
                  SizedBox(height: 12.h),
                  _buildInfoSection('Work Information', [
                    _infoRow(Icons.business_outlined, 'Department', employee.department),
                    _infoRow(Icons.work_outline_rounded, 'Designation', employee.designation),
                    _infoRow(Icons.category_outlined, 'Employee Type', employee.employeeType),
                    _infoRow(Icons.calendar_today_outlined, 'Joining Date', employee.joiningDate),
                    if (employee.reportingTo != null)
                      _infoRow(Icons.supervisor_account_outlined, 'Reports To', employee.reportingTo!),
                  ]),
                  SizedBox(height: 12.h),
                  _buildInfoSection('Contact Information', [
                    _infoRow(Icons.email_outlined, 'Email', employee.email),
                    _infoRow(Icons.phone_outlined, 'Phone', employee.phone),
                  ]),
                  SizedBox(height: 12.h),
                  _buildPayrollSection(employee),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Employee employee) {
    final initials = AppHelpers.getInitials(employee.name);
    final avatarBg = AppHelpers.getAvatarColor(employee.name);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 28.h),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              _HeaderIconButton(
                icon: Icons.edit_rounded,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: avatarBg,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            employee.name,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            employee.designation,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: employee.isActive
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: employee.isActive ? AppColors.success : AppColors.error,
              ),
            ),
            child: Text(
              employee.isActive ? '● Active' : '● Inactive',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: employee.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Employee employee) {
    return Row(
      children: [
        Expanded(child: _statCard(
          '₹${(employee.salary / 1000).toStringAsFixed(0)}K',
          'Monthly',
          Icons.currency_rupee_rounded,
          AppColors.primary,
          AppColors.primarySurface,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _statCard(
          '${employee.leaveBalance}',
          'Leave Left',
          Icons.event_available_rounded,
          AppColors.success,
          AppColors.successLight,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _statCard(
          employee.employeeType == 'Full-time' ? 'FT' : 'PT',
          'Emp Type',
          Icons.work_rounded,
          AppColors.secondary,
          AppColors.secondaryLight,
        )),
      ],
    );
  }

  Widget _statCard(
    String value,
    String label,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16.sp),
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
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
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

  Widget _buildPayrollSection(Employee employee) {
    final gross = employee.salary;
    final pf = gross * 0.12;
    final esi = gross * 0.0175;
    final net = gross - pf - esi;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payroll Summary',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(child: _payItem('Basic Salary', AppHelpers.formatCurrency(gross))),
              Expanded(child: _payItem('PF (12%)', AppHelpers.formatCurrency(pf))),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _payItem('ESI (1.75%)', AppHelpers.formatCurrency(esi))),
              Expanded(child: _payItem('Net Salary', AppHelpers.formatCurrency(net), highlight: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payItem(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: highlight ? 16.sp : 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}