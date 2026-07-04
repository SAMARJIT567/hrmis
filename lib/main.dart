// ============================================================
// main.dart — App Entry Point
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

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
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Maps Renderer (Once and safely) ──
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // 1. Switch to the 'latest' renderer for better performance and stability
    // 2. Avoid forcing 'useAndroidViewSurface' which causes qdgralloc errors on some devices
    try {
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    } catch (e) {
      debugPrint('Maps initialization error: $e');
    }
  }

  await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const HRMISApp());
}

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
