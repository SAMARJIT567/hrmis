// ============================================================
// 📁 lib/features/employees/screens/employees_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_card_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/loading_widget.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildDepartmentTabs(),
          _buildSummaryStats(),
          Expanded(child: _buildEmployeeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(Icons.person_add_rounded, size: 20.sp),
        label: Text(
          AppStrings.addEmployee,
          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 20.h, 20.w, 20.h),
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
                  AppStrings.employees,
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your workforce',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          _headerIconBtn(Icons.notifications_outlined),
          SizedBox(width: 10.w),
          _headerIconBtn(Icons.filter_list_rounded),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon) {
    return Container(
      width: 38.w,
      height: 38.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
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
          Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => context.read<EmployeeProvider>().search(val),
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchEmployee,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                context.read<EmployeeProvider>().search('');
              },
              child: Icon(Icons.close, color: AppColors.textTertiary, size: 18.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildDepartmentTabs() {
    return Consumer<EmployeeProvider>(
      builder: (_, provider, __) {
        final depts = provider.departments;
        return Container(
          height: 46.h,
          margin: EdgeInsets.only(top: 14.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: depts.length,
            itemBuilder: (_, i) {
              final dept = depts[i];
              final isSelected = provider.selectedDept == dept;
              return GestureDetector(
                onTap: () => provider.filterByDepartment(dept),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dept,
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

  Widget _buildSummaryStats() {
    return Consumer<EmployeeProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
          child: Row(
            children: [
              Text(
                '${provider.employees.length} of ${provider.totalCount} employees',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _statusChip('All', provider),
              SizedBox(width: 6.w),
              _statusChip('active', provider),
              SizedBox(width: 6.w),
              _statusChip('inactive', provider),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status, EmployeeProvider provider) {
    final isSelected = provider.selectedStatus == status;
    final label = status == 'All' ? 'All' : status == 'active' ? 'Active' : 'Inactive';
    return GestureDetector(
      onTap: () => provider.filterByStatus(status),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Consumer<EmployeeProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: InlineLoader());
        }

        if (provider.employees.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.person_search_rounded,
            title: 'No Employees Found',
            subtitle: 'Try adjusting your search or filters.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadEmployees,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 80.h),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.employees.length,
            itemBuilder: (_, i) {
              final emp = provider.employees[i];
              return EmployeeCard(
                employee: emp,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/employee-detail',
                  arguments: emp.id,
                ),
              );
            },
          ),
        );
      },
    );
  }
}