// ============================================================
// 📁 lib/features/attendance/screens/employee_attendance_screen.dart
// ============================================================
// Dashboard Screen for Employees
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/employee_attendance_provider.dart';
import 'attendance_calendar_screen.dart';
import 'check_in_screen.dart';
import '../../leave/screens/employee_leave_screen.dart';
import '../../leave/providers/leave_provider.dart';
import '../../leave/models/leave_model.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  int _visibleCount = 5;
  late int _leaveFilterMonth;
  late int _leaveFilterYear;
  final List<int> _yearsList = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _leaveFilterMonth = now.month;
    _leaveFilterYear = now.year;
  }

  void _initializeYearsList(String? joiningDateStr) {
    if (_yearsList.isNotEmpty) return;
    
    final now = DateTime.now();
    int startYear = now.year - 2; // Default fallback: last 3 years
    
    if (joiningDateStr != null && joiningDateStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(joiningDateStr);
        startYear = parsed.year;
      } catch (_) {
        try {
          final parsed = DateFormat('dd MMM yyyy').parse(joiningDateStr);
          startYear = parsed.year;
        } catch (_) {}
      }
    }
    
    if (startYear > now.year) {
      startYear = now.year;
    }
    
    _yearsList.clear();
    for (int y = now.year; y >= startYear; y--) {
      _yearsList.add(y);
    }
    
    if (!_yearsList.contains(_leaveFilterYear)) {
      _leaveFilterYear = _yearsList.first;
    }
  }

  List<int> _getActiveMonths(String? joiningDateStr) {
    int joiningYear = 0;
    int joiningMonth = 1;
    
    if (joiningDateStr != null && joiningDateStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(joiningDateStr);
        joiningYear = parsed.year;
        joiningMonth = parsed.month;
      } catch (_) {
        try {
          final parsed = DateFormat('dd MMM yyyy').parse(joiningDateStr);
          joiningYear = parsed.year;
          joiningMonth = parsed.month;
        } catch (_) {}
      }
    }
    
    if (_leaveFilterYear == joiningYear) {
      return List.generate(12 - joiningMonth + 1, (index) => joiningMonth + index);
    }
    
    return List.generate(12, (index) => index + 1);
  }

  DateTime? _parseAnyDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      if (dateStr.contains(RegExp(r'[a-zA-Z]'))) {
        return DateFormat('dd MMM yyyy').parse(dateStr);
      } else {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      }
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  bool _isLeaveInPeriod(LeaveRequest request, int month, int year) {
    final fromDate = _parseAnyDate(request.fromDate);
    final toDate = _parseAnyDate(request.toDate);
    if (fromDate == null || toDate == null) return false;
    
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    return fromDate.isBefore(endOfMonth.add(const Duration(days: 1))) &&
           toDate.isAfter(startOfMonth.subtract(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    _initializeYearsList(user?.joiningDate);

    return Scaffold(
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
                _buildLeaveOverviewSection(context),
                _buildHistoryTitle(),
                _buildAttendanceHistory(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(AuthUser? user, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 85.h,
      collapsedHeight: 50.h,
      toolbarHeight: 50.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: null,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
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
                            Text('Welcome Back!', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                            Text(user?.name ?? 'Employee', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(AppHelpers.getInitials(user?.name ?? 'Employee'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5.r,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    _actionButton(
                      icon: Icons.login_rounded, 
                      label: 'Check In', 
                      color: AppColors.success, 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckInScreen()),
                        );
                      }
                    )
                  else
                    _actionButton(
                      icon: Icons.logout_rounded, 
                      label: 'Check Out', 
                      color: AppColors.error, 
                      onTap: () async {
                        // Show non-dismissible loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogCtx) => Center(
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              child: Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Locking GPS & Checking Out...',
                                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        try {
                          final locService = LocationService();
                          await locService.checkLocationServices();
                          await locService.requestPermission();
                          final locationData = await locService.getCurrentLocation();
                          final lat = locationData['latitude'] as double? ?? 0.0;
                          final lon = locationData['longitude'] as double? ?? 0.0;

                          final success = await provider.checkOut(
                            latitude: lat,
                            longitude: lon,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Pop the loading dialog
                          }

                          if (success && context.mounted) {
                            AppHelpers.showSuccess(context, 'Checked Out Successfully!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // Pop the loading dialog
                            AppHelpers.showError(context, e.toString());
                          }
                        }
                      }
                    ),
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
                context.read<NavigationProvider>().setIndex(1);
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
                context.read<NavigationProvider>().setIndex(2);
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
        final now = DateTime.now();
        int yearlyPresent = provider.records.where((r) {
          try {
            DateTime recordDate;
            if (r.date.contains(RegExp(r'[a-zA-Z]'))) {
              recordDate = DateFormat('dd MMM yyyy').parse(r.date);
            } else {
              recordDate = DateFormat('yyyy-MM-dd').parse(r.date);
            }
            return recordDate.year == now.year &&
                (r.status == 'Present' || r.status == 'Late' || r.status == 'Late In' || r.status == 'Half Day' || r.status == 'Tour' || r.status == 'Early Out');
          } catch (_) {
            return false;
          }
        }).length;

        int yearlyLate = provider.records.where((r) {
          try {
            DateTime recordDate;
            if (r.date.contains(RegExp(r'[a-zA-Z]'))) {
              recordDate = DateFormat('dd MMM yyyy').parse(r.date);
            } else {
              recordDate = DateFormat('yyyy-MM-dd').parse(r.date);
            }
            return recordDate.year == now.year &&
                (r.status == 'Late' || r.status == 'Late In');
          } catch (_) {
            return false;
          }
        }).length;

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
              _statItem('Present (Yearly)', yearlyPresent, AppColors.success),
              _statDivider(),
              _statItem('Late (Yearly)', yearlyLate, AppColors.warning),
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

  Widget _buildAttendanceHistory(BuildContext context) {
    return Consumer<EmployeeAttendanceProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: InlineLoader()));
        if (provider.records.isEmpty) return const EmptyStateWidget(icon: Icons.event_busy_rounded, title: 'No Attendance Records', subtitle: 'Your attendance history will appear here.');
        final recordsToShow = provider.records.take(_visibleCount).toList();

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: recordsToShow.length,
              itemBuilder: (_, i) {
                final record = recordsToShow[i];
                Color statusColor = AppColors.error;
                if (record.status == 'Present') {
                  statusColor = AppColors.success;
                } else if (record.status == 'Late' || record.status == 'Late In') {
                  statusColor = AppColors.warning;
                } else if (record.status == 'Leave') {
                  statusColor = Colors.purple;
                } else if (record.status == 'Tour') {
                  statusColor = Colors.indigo;
                } else if (record.status == 'Half Day') {
                  statusColor = Colors.blue;
                }
                return GestureDetector(
                  onTap: () => _showRecordDetails(context, record),
                  child: Container(
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
                              if (record.checkIn != null) Text('In: ${record.checkIn}  |  Out: ${record.checkOut ?? "Pending"}', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary)),
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
                  ),
                );
              },
            ),
            if (provider.records.length > _visibleCount) ...[
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _visibleCount += 5;
                  });
                },
                icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: AppColors.primary),
                label: Text(
                  'Load More',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showRecordDetails(BuildContext context, EmployeeAttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final statusColor = record.status == 'Present' ? AppColors.success : record.status == 'Late' || record.status == 'Late In' ? AppColors.warning : AppColors.error;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).padding.bottom + 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Attendance Details',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                record.date,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildModalTimeInfo(
                      Icons.login_rounded,
                      'Check In',
                      record.checkIn ?? '--:--',
                      AppColors.success,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildModalTimeInfo(
                      Icons.logout_rounded,
                      'Check Out',
                      record.checkOut ?? (record.checkIn != null ? 'Pending' : '--:--'),
                      record.checkOut != null ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ],
              ),
              if (record.checkInSelfie != null && record.checkInSelfie!.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Punch Selfie',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    record.checkInSelfie!,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100.h,
                      color: Colors.grey[50],
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey[400], size: 32.sp),
                      ),
                    ),
                  ),
                ),
              ],
              if (record.latitude != null && record.longitude != null) ...[
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Location Coordinates',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Lat: ${record.latitude}  |  Lng: ${record.longitude}',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaveOverviewSection(BuildContext context) {
    final leaveProv = context.watch<LeaveProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (leaveProv.isLoading || leaveProv.policies.isEmpty) {
      return const SizedBox.shrink();
    }

    final myRequests = leaveProv.allRequests.where((r) => r.employeeId == user?.id).toList();
    final myCompOffs = leaveProv.compOffReports.where((c) => c.employeeId == user?.id && c.status == 'approved').toList();

    final activeMonths = _getActiveMonths(user?.joiningDate);
    if (!activeMonths.contains(_leaveFilterMonth)) {
      _leaveFilterMonth = activeMonths.first;
    }

    // 1. Calculate General Period Stats
    double periodTaken = 0.0;
    for (var r in myRequests) {
      if (r.status == 'approved' || r.status == 'closed') {
        if (_isLeaveInPeriod(r, _leaveFilterMonth, _leaveFilterYear)) {
          periodTaken += r.days;
        }
      }
    }

    // 2. Calculate Total Allowed & Remaining (All policies combined)
    int totalAllowed = 0;
    int totalUsed = 0;
    for (var p in leaveProv.policies) {
      int allowed = p.totalDays;
      if (p.id == 'CO') {
        allowed += myCompOffs.length;
      }
      totalAllowed += allowed;
      totalUsed += p.usedDays;
    }
    int totalRemaining = totalAllowed - totalUsed;
    if (totalRemaining < 0) totalRemaining = 0;

    final selectedMonthName = DateFormat('MMM').format(DateTime(2026, _leaveFilterMonth, 1));

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 2))
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: My Leaves & Dropdowns
          Row(
            children: [
              Text(
                'My Leaves',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Month Selector Dropdown
              Container(
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _leaveFilterMonth,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 16.sp),
                    style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: activeMonths.map((m) {
                      final name = DateFormat('MMM').format(DateTime(2026, m, 1));
                      return DropdownMenuItem<int>(
                        value: m,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _leaveFilterMonth = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // Year Selector Dropdown
              Container(
                height: 28.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _leaveFilterYear,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 16.sp),
                    style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: _yearsList.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text('$y'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _leaveFilterYear = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Overview Stats Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOverviewStatCard(
                  'Taken in $selectedMonthName',
                  '${periodTaken % 1 == 0 ? periodTaken.toInt() : periodTaken}',
                  AppColors.warning,
                ),
                SizedBox(width: 8.w),
                _buildOverviewStatCard(
                  'Remaining Total',
                  '$totalRemaining',
                  AppColors.success,
                ),
                SizedBox(width: 8.w),
                _buildOverviewStatCard(
                  'Allowed Yearly',
                  '$totalAllowed',
                  AppColors.primary,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1, color: AppColors.border.withOpacity(0.5)),
          SizedBox(height: 12.h),

          // Title for detailed balances
          Text(
            'Leave Type Details',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),

          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaveProv.policies.length,
            itemBuilder: (ctx, idx) {
              final policy = leaveProv.policies[idx];
              int allowed = policy.totalDays;
              if (policy.id == 'CO') {
                allowed += myCompOffs.length;
              }
              int remaining = allowed - policy.usedDays;
              if (remaining < 0) remaining = 0;

              double periodTakenForType = 0.0;
              for (var r in myRequests) {
                if (r.leaveType.toLowerCase() == policy.title.toLowerCase() &&
                    (r.status == 'approved' || r.status == 'closed')) {
                  if (_isLeaveInPeriod(r, _leaveFilterMonth, _leaveFilterYear)) {
                    periodTakenForType += r.days;
                  }
                }
              }

              final progress = allowed > 0 ? (remaining / allowed) : 0.0;
              final color = Color(policy.colorValue);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            AppHelpers.getLeaveIcon(policy.iconName),
                            color: color,
                            size: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Taken in $selectedMonthName: ${periodTakenForType % 1 == 0 ? periodTakenForType.toInt() : periodTakenForType}  |  Total Allowed: $allowed',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.sp,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$remaining Left',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.1),
                        color: color,
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTimeInfo(IconData icon, String label, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
