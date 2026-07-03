// ============================================================
// 📁 lib/features/payroll/screens/payroll_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/payroll_provider.dart';
import '../models/payroll_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

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
                  _buildTotalCard(),
                  _buildFilterRow(),
                  _buildPayrollList(),
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
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 22.h),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payroll',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage salary and pay slips',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  'May 2025',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Consumer<PayrollProvider>(
      builder: (_, prov, __) => Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Payroll — May 2025',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppHelpers.formatCurrency(prov.totalNetPayroll),
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _totalStat('Total', '${prov.records.length}', Colors.white.withOpacity(0.6)),
                SizedBox(width: 24.w),
                _totalStat('Paid', '${prov.paidCount}', AppColors.success),
                SizedBox(width: 24.w),
                _totalStat('Pending', '${prov.pendingCount}', AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final filters = ['All', 'paid', 'pending', 'processing'];
    return Consumer<PayrollProvider>(
      builder: (_, prov, __) => Container(
        height: 44.h,
        margin: EdgeInsets.only(bottom: 12.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: filters.length,
          itemBuilder: (_, i) {
            final f = filters[i];
            final isSelected = prov.filter == f;
            final label = f[0].toUpperCase() + f.substring(1);
            return GestureDetector(
              onTap: () => prov.filterBy(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
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
      ),
    );
  }

  Widget _buildPayrollList() {
    return Consumer<PayrollProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading) return Padding(
          padding: EdgeInsets.all(32.r),
          child: const InlineLoader(),
        );
        if (prov.records.isEmpty) return const EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'No Payroll Records',
          subtitle: 'No records match this filter.',
        );
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: prov.records.length,
          itemBuilder: (_, i) => _PayrollCard(record: prov.records[i]),
        );
      },
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final PayrollRecord record;
  const _PayrollCard({required this.record});

  Color get _statusColor => record.status == 'paid'
      ? AppColors.payrollPaid
      : record.status == 'pending'
          ? AppColors.payrollPending
          : AppColors.info;

  @override
  Widget build(BuildContext context) {
    final initials = AppHelpers.getInitials(record.employeeName);
    final avatarBg = AppHelpers.getAvatarColor(record.employeeName);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 3)),
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
                        record.employeeName,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${record.designation} • ${record.department}',
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
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    record.status[0].toUpperCase() + record.status.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Expanded(child: _salaryItem('Gross', AppHelpers.formatCurrency(record.grossSalary), AppColors.primary)),
                Expanded(child: _salaryItem('Deductions', '-${AppHelpers.formatCurrency(record.totalDeductions)}', AppColors.error)),
                Expanded(child: _salaryItem('Net Pay', AppHelpers.formatCurrency(record.netSalary), AppColors.success)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.paidOn != null
                      ? 'Paid on: ${record.paidOn}'
                      : 'Month: ${record.month}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded, color: AppColors.primary, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Pay Slip',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textTertiary),
        ),
        SizedBox(height: 2.h),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}