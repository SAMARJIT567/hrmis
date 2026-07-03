// ============================================================
// features/dashboard/screens/dashboard_screen.dart
// ============================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../employees/providers/employee_provider.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../leave/providers/leave_provider.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/quick_action_widget.dart';
import '../widgets/recent_activity_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
      context.read<AttendanceProvider>().loadAttendance();
      context.read<LeaveProvider>().loadLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final empProv = context.watch<EmployeeProvider>();
    final attProv = context.watch<AttendanceProvider>();
    final leaveProv = context.watch<LeaveProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            context.read<EmployeeProvider>().loadEmployees(),
            context.read<AttendanceProvider>().loadAttendance(),
            context.read<LeaveProvider>().loadLeaves(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverHeader(auth),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD.w,
                vertical: AppDimensions.paddingMD.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatCards(empProv, attProv, leaveProv),
                  SizedBox(height: 24.h),
                  _sectionTitle('Attendance Overview', 'This week'),
                  SizedBox(height: 12.h),
                  _buildAttendanceChart(),
                  SizedBox(height: 24.h),
                  _sectionTitle('Departments', '${empProv.employees.length} total'),
                  SizedBox(height: 12.h),
                  _buildDepartmentChart(empProv),
                  SizedBox(height: 24.h),
                  _sectionTitle('Quick Actions', ''),
                  SizedBox(height: 12.h),
                  const QuickActionsSection(),
                  SizedBox(height: 24.h),
                  _sectionTitle('Recent Activity', 'View all'),
                  SizedBox(height: 12.h),
                  const RecentActivitySection(),
                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(AuthProvider auth) {
    return SliverAppBar(
      expandedHeight: 160.h,
      collapsedHeight: 70.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      toolbarHeight: 70.h,
      title: Text(
        'Dashboard',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        title: null,
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.paddingMD.w,
                AppDimensions.paddingSM.h,
                AppDimensions.paddingMD.w,
                AppDimensions.paddingMD.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HRMIS',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        children: [
                          _HeaderIconBtn(
                            icon: Icons.notifications_outlined,
                            badge: '3',
                            onTap: () {},
                          ),
                          SizedBox(width: 8.w),
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              AppHelpers.getInitials(
                                auth.currentUser?.name ?? 'Admin',
                              ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppHelpers.getGreeting(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    auth.currentUser?.name ?? 'Administrator',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(
    EmployeeProvider emp,
    AttendanceProvider att,
    LeaveProvider leave,
  ) {
    final cards = [
      _StatData('Total Employees', '${emp.employees.length}',
          Icons.people_alt, AppColors.primary, AppColors.primarySurface, '+2', true),
      _StatData('Present Today', '${att.presentCount}',
          Icons.how_to_reg, AppColors.success, AppColors.successLight, '+5%', true),
      _StatData('On Leave', '${leave.pendingCount}',
          Icons.event_note, AppColors.warning, AppColors.warningLight, null, true),
      _StatData('Absent Today', '${att.absentCount}',
          Icons.person_off, AppColors.error, AppColors.errorLight, '-2', false),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14.h,
      crossAxisSpacing: 14.w,
      childAspectRatio: 1.45,
      children: cards.map((c) => StatCard(
        label: c.label,
        value: c.value,
        icon: c.icon,
        iconColor: c.iconColor,
        iconBgColor: c.iconBg,
        trend: c.trend,
        trendUp: c.trendUp,
      )).toList(),
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      height: 200.h,
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 16.w, 8.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _LegendDot(color: AppColors.success, label: 'Present'),
              SizedBox(width: 12.w),
              _LegendDot(color: AppColors.warning, label: 'Leave'),
              SizedBox(width: 12.w),
              _LegendDot(color: AppColors.error, label: 'Absent'),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                      rod.toY.toInt().toString(),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][v.toInt()],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 10,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _bar(0, 24, 4, 2),
                  _bar(1, 26, 2, 2),
                  _bar(2, 23, 3, 4),
                  _bar(3, 25, 2, 3),
                  _bar(4, 22, 3, 5),
                  _bar(5, 10, 1, 1),
                  _bar(6, 5, 0, 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double present, double leave, double absent) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: present,
          color: AppColors.success,
          width: 7.w,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: leave,
          color: AppColors.warning,
          width: 7.w,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: absent,
          color: AppColors.error,
          width: 7.w,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildDepartmentChart(EmployeeProvider emp) {
    final deptCounts = emp.departmentCounts;
    if (deptCounts.isEmpty) return const SizedBox.shrink();

    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];

    final entries = deptCounts.entries.toList();

    return Container(
      height: 160.h,
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
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35.r,
                sections: List.generate(entries.length, (i) {
                  return PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: colors[i % colors.length],
                    radius: 30.r,
                    showTitle: false,
                  );
                }),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(entries.length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            entries[i].key,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '(${entries[i].value})',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: EdgeInsets.all(3.r),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? trend;
  final bool trendUp;
  const _StatData(
    this.label,
    this.value,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.trend,
    this.trendUp,
  );
}