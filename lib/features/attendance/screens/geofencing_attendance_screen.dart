// ============================================================
// 📁 lib/features/attendance/screens/geofencing_attendance_screen.dart
// ============================================================
// Geofencing based attendance with location verification
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/time_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/office_settings_model.dart';

class GeofencingAttendanceScreen extends StatefulWidget {
  const GeofencingAttendanceScreen({super.key});

  @override
  State<GeofencingAttendanceScreen> createState() => _GeofencingAttendanceScreenState();
}

class _GeofencingAttendanceScreenState extends State<GeofencingAttendanceScreen> {
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;
  bool _isCheckingLocation = false;
  bool _isWithinRange = false;
  double _distanceFromOffice = 0.0;
  String? _currentAddress;
  String? _errorMessage;
  
  OfficeSettings _officeSettings = OfficeSettings.defaultSettings;
  
  // Location tracking
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    _loadOfficeSettings();
  }

  Future<void> _loadOfficeSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading office settings
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _officeSettings = OfficeSettings.defaultSettings;
      _isLoading = false;
    });
  }

  Future<void> _checkLocationAndAttendance() async {
    setState(() {
      _isCheckingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check location services
      final isServiceEnabled = await _locationService.checkLocationServices();
      if (!isServiceEnabled) {
        setState(() {
          _errorMessage = 'Please enable location services';
          _isCheckingLocation = false;
        });
        return;
      }

      // Request permission
      final isPermissionGranted = await _locationService.requestPermission();
      if (!isPermissionGranted) {
        setState(() {
          _errorMessage = 'Location permission required';
          _isCheckingLocation = false;
        });
        return;
      }

      // Get current location
      final location = await _locationService.getCurrentLocation();
      _currentLatitude = location['latitude'] as double?;
      _currentLongitude = location['longitude'] as double?;
      _currentAddress = location['address'] as String?;

      if (_currentLatitude == null || _currentLongitude == null) {
        setState(() {
          _errorMessage = 'Failed to get location';
          _isCheckingLocation = false;
        });
        return;
      }

      // Calculate distance from office
      _distanceFromOffice = _locationService.calculateDistance(
        lat1: _currentLatitude!,
        lon1: _currentLongitude!,
        lat2: _officeSettings.latitude,
        lon2: _officeSettings.longitude,
      );

      // Check if within allowed radius
      _isWithinRange = _distanceFromOffice * 1000 <= _officeSettings.allowedRadiusMeters;

      setState(() {
        _isCheckingLocation = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isCheckingLocation = false;
      });
    }
  }

  Future<void> _markAttendance(String status) async {
    if (!_isWithinRange && !_officeSettings.allowRemoteCheckIn) {
      AppHelpers.showError(
        context, 
        'You are outside the office range!\nDistance: ${(_distanceFromOffice * 1000).toStringAsFixed(0)}m away'
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      AppHelpers.showSuccess(
        context, 
        '$status marked successfully!\nLocation: ${_currentAddress ?? "Unknown"}'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Geo-Attendance',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {
              // Navigate to office settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── User Info Card ──────────────────────────
                  _buildUserInfoCard(user),
                  SizedBox(height: 16.h),

                  // ─── Office Info Card ────────────────────────
                  _buildOfficeInfoCard(),
                  SizedBox(height: 16.h),

                  // ─── Location Card ───────────────────────────
                  _buildLocationCard(),
                  SizedBox(height: 16.h),

                  // ─── Attendance Buttons ──────────────────────
                  _buildAttendanceButtons(),
                  SizedBox(height: 16.h),

                  // ─── Today's Attendance ──────────────────────
                  _buildTodayAttendance(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard(AuthUser? user) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              AppHelpers.getInitials(user?.name ?? 'U'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.designation ?? user?.email ?? 'Employee',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'ID: ${user?.id ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Today',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Office Details',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _infoRow(Icons.storefront_rounded, 'Office', _officeSettings.officeName),
          _infoRow(Icons.location_on_rounded, 'Address', _officeSettings.officeAddress),
          _infoRow(Icons.access_time_rounded, 'Timing', 
            '${_officeSettings.checkInTime} - ${_officeSettings.checkOutTime}'),
          _infoRow(Icons.timer_outlined, 'Working Hours', 
            '${_officeSettings.workingHoursPerDay} hrs (Break: ${_officeSettings.breakDurationMinutes} min)'),
          _infoRow(Icons.straighten_rounded, 'Allowed Radius', 
            '${_officeSettings.allowedRadiusMeters.toStringAsFixed(0)} meters'),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isWithinRange ? AppColors.success : AppColors.border,
          width: _isWithinRange ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: _isWithinRange ? AppColors.success : AppColors.warning,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Current Location',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_isCheckingLocation)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
                  onPressed: _checkLocationAndAttendance,
                  iconSize: 20.sp,
                ),
            ],
          ),
          SizedBox(height: 10.h),
          
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_currentLatitude != null) ...[
            _infoRow(Icons.pin_drop_rounded, 'Latitude', _currentLatitude?.toStringAsFixed(6) ?? 'N/A'),
            _infoRow(Icons.pin_drop_rounded, 'Longitude', _currentLongitude?.toStringAsFixed(6) ?? 'N/A'),
            _infoRow(Icons.streetview_rounded, 'Address', _currentAddress ?? 'Fetching...'),
            Divider(color: AppColors.border, height: 12.h),
            Row(
              children: [
                Icon(
                  _isWithinRange ? Icons.check_circle : Icons.warning_rounded,
                  color: _isWithinRange ? AppColors.success : AppColors.error,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _isWithinRange
                      ? '✅ Within office range (${(_distanceFromOffice * 1000).toStringAsFixed(0)}m)'
                      : '⚠️ Outside office range (${(_distanceFromOffice * 1000).toStringAsFixed(0)}m)',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _isWithinRange ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
          
          SizedBox(height: 12.h),
          CustomButton(
            label: _currentLatitude == null ? 'Check Location' : 'Refresh Location',
            onPressed: _checkLocationAndAttendance,
            prefixIcon: _currentLatitude == null ? Icons.my_location_rounded : Icons.refresh_rounded,
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Check In',
                  onPressed: () => _markAttendance('Check In'),
                  prefixIcon: Icons.login_rounded,
                  backgroundColor: AppColors.success,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  label: 'Check Out',
                  onPressed: () => _markAttendance('Check Out'),
                  prefixIcon: Icons.logout_rounded,
                  backgroundColor: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Break Start',
                  onPressed: () => _markAttendance('Break Start'),
                  prefixIcon: Icons.free_breakfast_rounded,
                  type: ButtonType.outline,
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.warning,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  label: 'Break End',
                  onPressed: () => _markAttendance('Break End'),
                  prefixIcon: Icons.play_arrow_rounded,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendance() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Attendance',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _attendanceStatusItem(
                'Check In',
                '09:05 AM',
                Icons.login_rounded,
                AppColors.success,
              ),
              _attendanceDivider(),
              _attendanceStatusItem(
                'Check Out',
                '--:-- --',
                Icons.logout_rounded,
                AppColors.textTertiary,
              ),
              _attendanceDivider(),
              _attendanceStatusItem(
                'Hours',
                '5h 30m',
                Icons.timer_outlined,
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceStatusItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: AppColors.border,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textTertiary),
          SizedBox(width: 8.w),
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}