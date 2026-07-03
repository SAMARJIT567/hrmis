// ============================================================
// navigation/main_navigation.dart
// ============================================================
// 4 TABS: Dashboard, Calendar, Leave, Profile
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/employees/screens/employees_screen.dart';
import '../features/attendance/screens/attendance_screen.dart';
import '../features/attendance/screens/employee_attendance_screen.dart';
import '../features/attendance/screens/attendance_calendar_screen.dart';
import '../features/leave/screens/leave_screen.dart';
import '../features/leave/screens/employee_leave_screen.dart';
import '../features/payroll/screens/payroll_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // For Admin
  late final List<Widget> _adminScreens;
  late final List<_NavItem> _adminNavItems;

  // For Non-Admin (Employee) - 4 TABS
  late final List<Widget> _employeeScreens;
  late final List<_NavItem> _employeeNavItems;

  @override
  void initState() {
    super.initState();

    // Admin Screens
    _adminScreens = [
      const DashboardScreen(),
      const EmployeesScreen(),
      const AttendanceScreen(),
      const LeaveScreen(),
      const PayrollScreen(),
      const ProfileScreen(),
    ];
    _adminNavItems = const [
      _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
      _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Employees'),
      _NavItem(icon: Icons.access_time_outlined, activeIcon: Icons.access_time_filled, label: 'Attendance'),
      _NavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'Leave'),
      _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Payroll'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    // Employee Screens - 4 TABS
    _employeeScreens = [
      const EmployeeAttendanceScreen(),
      const AttendanceCalendarScreen(),
      const EmployeeLeaveScreen(),
      const ProfileScreen(),
    ];
    _employeeNavItems = const [
      _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
      _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendar'),
      _NavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'Leave'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: isAdmin ? _adminScreens : _employeeScreens,
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
        items: (isAdmin ? _adminNavItems : _employeeNavItems).map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon, size: 22.sp),
            activeIcon: Icon(item.activeIcon, size: 22.sp),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}