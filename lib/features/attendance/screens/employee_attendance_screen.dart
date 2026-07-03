// ============================================================
// 📁 lib/features/attendance/screens/employee_attendance_screen.dart
// ============================================================
// Dashboard Screen - Bottom navigation parent se milega
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import 'attendance_calendar_screen.dart';
import '../../leave/screens/employee_leave_screen.dart';

class EmployeeAttendanceRecord {
  final String id;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? workHours;
  final String? lateDuration;

  const EmployeeAttendanceRecord({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workHours,
    this.lateDuration,
  });
}

class EmployeeAttendanceProvider extends ChangeNotifier {
  List<EmployeeAttendanceRecord> _records = [];
  bool _isLoading = false;
  bool _isCheckedIn = false;
  String? _currentCheckInTime;
  String? _currentLateDuration;

  List<EmployeeAttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  bool get isCheckedIn => _isCheckedIn;
  String? get currentCheckInTime => _currentCheckInTime;
  String? get currentLateDuration => _currentLateDuration;

  int get presentCount => _records.where((r) => r.status == 'Present').length;
  int get absentCount => _records.where((r) => r.status == 'Absent').length;
  int get lateCount => _records.where((r) => r.status == 'Late').length;

  EmployeeAttendanceProvider() {
    loadMyAttendance();
    _checkTodayAttendance();
  }

  Future<void> loadMyAttendance() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    _records = [
      const EmployeeAttendanceRecord(id: '1', date: '20 May 2025', checkIn: '09:05 AM', checkOut: '06:10 PM', status: 'Present', workHours: '9h 5m', lateDuration: null),
      const EmployeeAttendanceRecord(id: '2', date: '19 May 2025', checkIn: '09:00 AM', checkOut: '06:00 PM', status: 'Present', workHours: '9h 0m', lateDuration: null),
      const EmployeeAttendanceRecord(id: '3', date: '18 May 2025', checkIn: '09:45 AM', checkOut: '06:15 PM', status: 'Late', workHours: '8h 30m', lateDuration: '15 minutes'),
      const EmployeeAttendanceRecord(id: '4', date: '17 May 2025', checkIn: null, checkOut: null, status: 'Absent', workHours: null, lateDuration: null),
      const EmployeeAttendanceRecord(id: '5', date: '16 May 2025', checkIn: '10:30 AM', checkOut: '06:05 PM', status: 'Late', workHours: '7h 35m', lateDuration: '30 minutes'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkTodayAttendance() async {
    final today = DateFormat('dd MMM yyyy').format(DateTime.now());
    final todayRecord = _records.firstWhere(
      (r) => r.date == today,
      orElse: () => const EmployeeAttendanceRecord(id: '', date: '', status: 'Absent'),
    );
    _isCheckedIn = todayRecord.checkIn != null;
    _currentCheckInTime = todayRecord.checkIn;
    _currentLateDuration = todayRecord.lateDuration;
    notifyListeners();
  }

  String _calculateLateDuration(DateTime checkInTime) {
    final expectedTime = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 10, 0);
    if (checkInTime.isAfter(expectedTime)) {
      final difference = checkInTime.difference(expectedTime);
      final minutes = difference.inMinutes;
      if (minutes < 60) return '$minutes minutes';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours hour${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins minutes' : ''}';
    }
    return '';
  }

  Future<bool> checkIn() async {
    if (_isCheckedIn) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final checkInTime = DateFormat('hh:mm a').format(now);
    final today = DateFormat('dd MMM yyyy').format(now);
    final isLate = now.hour >= 10;
    final lateDuration = isLate ? _calculateLateDuration(now) : '';

    _records.insert(0, EmployeeAttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: today,
      checkIn: checkInTime,
      checkOut: null,
      status: isLate ? 'Late' : 'Present',
      workHours: null,
      lateDuration: isLate ? lateDuration : null,
    ));

    _isCheckedIn = true;
    _currentCheckInTime = checkInTime;
    _currentLateDuration = isLate ? lateDuration : null;
    notifyListeners();
    return true;
  }

  Future<bool> checkOut() async {
    if (!_isCheckedIn) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final checkOutTime = DateFormat('hh:mm a').format(now);
    final today = DateFormat('dd MMM yyyy').format(now);

    final index = _records.indexWhere((r) => r.date == today);
    if (index != -1) {
      final record = _records[index];
      final checkIn = DateFormat('hh:mm a').parse(record.checkIn!);
      final workDuration = now.difference(checkIn);
      final hours = workDuration.inHours;
      final minutes = workDuration.inMinutes % 60;

      _records[index] = EmployeeAttendanceRecord(
        id: record.id,
        date: record.date,
        checkIn: record.checkIn,
        checkOut: checkOutTime,
        status: record.status,
        workHours: '$hours h ${minutes}m',
        lateDuration: record.lateDuration,
      );
    }

    _isCheckedIn = false;
    _currentCheckInTime = null;
    _currentLateDuration = null;
    notifyListeners();
    return true;
  }
}

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return ChangeNotifierProvider(
      create: (_) => EmployeeAttendanceProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildStickyHeader(user, context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTodayCard(context),
                  _buildQuickActions(context),
                  _buildStatsRow(),
                  _buildHistoryTitle(),
                  _buildAttendanceHistory(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(AuthUser? user, BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 130.h,
      collapsedHeight: 70.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      title: Text('My Dashboard', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        title: null,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, topPadding + 20.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome Back!', style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white70)),
                            Text(user?.name ?? 'Employee', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(AppHelpers.getInitials(user?.name ?? 'Employee'), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    return Consumer<EmployeeAttendanceProvider>(
      builder: (_, provider, __) {
        final today = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

        return Container(
          margin: EdgeInsets.all(16.r),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            children: [
              Text(today, style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white70)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!provider.isCheckedIn)
                    _actionButton(icon: Icons.login_rounded, label: 'Check In', color: AppColors.success, onTap: () async {
                      final success = await provider.checkIn();
                      if (success && context.mounted) AppHelpers.showSuccess(context, 'Checked In Successfully!');
                    })
                  else
                    _actionButton(icon: Icons.logout_rounded, label: 'Check Out', color: AppColors.error, onTap: () async {
                      final success = await provider.checkOut();
                      if (success && context.mounted) AppHelpers.showSuccess(context, 'Checked Out Successfully!');
                    }),
                ],
              ),
              if (provider.isCheckedIn && provider.currentCheckInTime != null) ...[
                SizedBox(height: 12.h),
                Text('Checked in at: ${provider.currentCheckInTime}', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                if (provider.currentLateDuration != null && provider.currentLateDuration!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12.r)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: AppColors.warning, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text('Late by: ${provider.currentLateDuration}', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.warning)),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceCalendarScreen(),
                  ),
                );
              },
              child: _quickActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'View Attendance',
                subtitle: 'Tap to view calendar',
                color: AppColors.primary,
                bgColor: AppColors.primarySurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeLeaveScreen(),
                  ),
                );
              },
              child: _quickActionCard(
                icon: Icons.event_note_rounded,
                title: 'Leave Management',
                subtitle: 'Tap to apply leave',
                color: AppColors.secondary,
                bgColor: AppColors.secondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14.r)),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 6.h),
            Text(label, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<EmployeeAttendanceProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.r),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              _statItem('Present', provider.presentCount, AppColors.success),
              _statDivider(),
              _statItem('Late', provider.lateCount, AppColors.warning),
              _statDivider(),
              _statItem('Absent', provider.absentCount, AppColors.error),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: color)),
          SizedBox(height: 4.h),
          Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 30.h, color: AppColors.border);

  Widget _buildHistoryTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Recent Attendance', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Last 5 days', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Consumer<EmployeeAttendanceProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: InlineLoader()));
        if (provider.records.isEmpty) return const EmptyStateWidget(icon: Icons.event_busy_rounded, title: 'No Attendance Records', subtitle: 'Your attendance history will appear here.');

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: provider.records.length,
          itemBuilder: (_, i) {
            final record = provider.records[i];
            final statusColor = record.status == 'Present' ? AppColors.success : record.status == 'Late' ? AppColors.warning : AppColors.error;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Container(width: 4.w, height: 40.h, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2.r))),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.date, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        if (record.checkIn != null) Text('In: ${record.checkIn}  |  Out: ${record.checkOut ?? "—"}', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary)),
                        if (record.lateDuration != null && record.lateDuration!.isNotEmpty) Text('⏰ Late by: ${record.lateDuration}', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.warning)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                        child: Text(record.status, style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: statusColor)),
                      ),
                      if (record.workHours != null) ...[
                        SizedBox(height: 4.h),
                        Text(record.workHours!, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textTertiary)),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}