// ============================================================
// main.dart — App Entry Point
// ============================================================
// Initializes Flutter engine, sets system UI, wraps app in
// ScreenUtil for responsiveness, and registers all Providers.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/employees/providers/employee_provider.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/attendance/providers/employee_attendance_provider.dart';
import 'features/leave/providers/leave_provider.dart';
import 'features/payroll/providers/payroll_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/attendance/providers/office_settings_provider.dart';

void main() async {
  // ── Required before any platform calls ──────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── SharedPreferences init (for auth persistence) ────────
  await SharedPreferences.getInstance();

  // ── System UI style ──────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Lock orientation to portrait ─────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const HRMISApp());
}

/// Root widget — sets up ScreenUtil + all global providers
class HRMISApp extends StatelessWidget {
  const HRMISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EmployeeProvider()),
            ChangeNotifierProvider(create: (_) => AttendanceProvider()),
            ChangeNotifierProvider(create: (_) => EmployeeAttendanceProvider()),
            ChangeNotifierProvider(create: (_) => LeaveProvider()),
            ChangeNotifierProvider(create: (_) => PayrollProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => OfficeSettingsProvider()),
          ],
          child: const AppRoot(),
        );
      },
    );
  }
}