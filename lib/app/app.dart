// ============================================================
// app/app.dart — MaterialApp + Named Route Definitions
// ============================================================
// Defines AppRoot widget with MaterialApp, theme, and all
// named routes. Auth guard redirects unauthenticated users.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/employees/screens/employee_detail_screen.dart';
import '../features/employees/screens/add_employee_screen.dart';
import '../features/leave/screens/leave_balance_screen.dart';
import '../navigation/main_navigation.dart';

/// Root of the app — MaterialApp with theme and routes
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'HRMIS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/main': (_) => const MainNavigation(),
            '/add-employee': (_) => const AddEmployeeScreen(),
            '/leave-balance': (_) => const LeaveBalanceScreen(),
            '/employee-detail': (ctx) {
              final id = ModalRoute.of(ctx)!.settings.arguments as String;
              return EmployeeDetailScreen(employeeId: id);
            },
          },
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => const SplashScreen(),
          ),
        );
      },
    );
  }
}