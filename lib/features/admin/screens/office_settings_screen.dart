// ============================================================
// 📁 lib/features/admin/screens/office_settings_screen.dart
// ============================================================
// Admin screen for office settings configuration
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/time_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class OfficeSettingsScreen extends StatefulWidget {
  const OfficeSettingsScreen({super.key});

  @override
  State<OfficeSettingsScreen> createState() => _OfficeSettingsScreenState();
}

class _OfficeSettingsScreenState extends State<OfficeSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ────────────────────────────────────────────
  final _officeNameController = TextEditingController(text: 'TechCorp Pvt. Ltd.');
  final _officeAddressController = TextEditingController(text: 'New Delhi, India');
  final _officeLatitudeController = TextEditingController(text: '28.6139');
  final _officeLongitudeController = TextEditingController(text: '77.2090');
  final _checkInTimeController = TextEditingController(text: '09:00 AM');
  final _checkOutTimeController = TextEditingController(text: '06:00 PM');
  final _workingHoursController = TextEditingController(text: '8');
  final _breakDurationController = TextEditingController(text: '30');

  // ─── State ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isCheckInRequired = true;
  bool _isCheckOutRequired = true;
  bool _isLocationTrackingEnabled = true;
  bool _isBiometricEnabled = false;
  String _selectedTimeZone = 'Asia/Kolkata';

  final List<String> _timeZones = [
    'Asia/Kolkata',
    'Asia/Dubai',
    'Asia/Singapore',
    'Europe/London',
    'America/New_York',
    'America/Los_Angeles',
  ];

  @override
  void dispose() {
    _officeNameController.dispose();
    _officeAddressController.dispose();
    _officeLatitudeController.dispose();
    _officeLongitudeController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    _workingHoursController.dispose();
    _breakDurationController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Office settings saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    final location = LocationService();
    await location.requestPermission();
    final currentLocation = await location.getCurrentLocation();

    setState(() {
      _officeLatitudeController.text = currentLocation['latitude']?.toString() ?? '0.0';
      _officeLongitudeController.text = currentLocation['longitude']?.toString() ?? '0.0';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Office Settings',
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
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Office Details ──────────────────────
                    _sectionTitle('Office Details'),
                    SizedBox(height: 12.h),
                    _buildOfficeDetailsCard(),

                    SizedBox(height: 20.h),

                    // ─── Location Settings ────────────────────
                    _sectionTitle('Location Settings'),
                    SizedBox(height: 12.h),
                    _buildLocationCard(),

                    SizedBox(height: 20.h),

                    // ─── Attendance Settings ──────────────────
                    _sectionTitle('Attendance Settings'),
                    SizedBox(height: 12.h),
                    _buildAttendanceCard(),

                    SizedBox(height: 20.h),

                    // ─── Advanced Settings ────────────────────
                    _sectionTitle('Advanced Settings'),
                    SizedBox(height: 12.h),
                    _buildAdvancedCard(),

                    SizedBox(height: 30.h),

                    // ─── Save Button ──────────────────────────
                    CustomButton(
                      label: 'Save All Settings',
                      onPressed: _saveSettings,
                      prefixIcon: Icons.save_rounded,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOfficeDetailsCard() {
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
          CustomTextField(
            label: 'Office Name',
            hint: 'Enter office name',
            controller: _officeNameController,
            prefixIcon: Icons.business_outlined,
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter office name' : null,
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Office Address',
            hint: 'Enter office address',
            controller: _officeAddressController,
            prefixIcon: Icons.location_on_outlined,
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter office address' : null,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Time Zone',
                  hint: 'Select time zone',
                  controller: TextEditingController(text: _selectedTimeZone),
                  prefixIcon: Icons.access_time,
                  readOnly: true,
                  onTap: _showTimeZonePicker,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  label: 'Working Days',
                  hint: 'Mon-Sat',
                  controller: TextEditingController(text: 'Mon-Sat'),
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                ),
              ),
            ],
          ),
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
                child: CustomTextField(
                  label: 'Office Latitude',
                  hint: 'Enter latitude',
                  controller: _officeLatitudeController,
                  prefixIcon: Icons.pin_drop_outlined,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter latitude' : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  label: 'Office Longitude',
                  hint: 'Enter longitude',
                  controller: _officeLongitudeController,
                  prefixIcon: Icons.pin_drop_outlined,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter longitude' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomButton(
            label: 'Get Current Location',
            onPressed: _getCurrentLocation,
            prefixIcon: Icons.my_location_rounded,
            type: ButtonType.outline,
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            title: Text(
              'Enable Location Tracking',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Track employee location during check-in',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: _isLocationTrackingEnabled,
            onChanged: (val) => setState(() => _isLocationTrackingEnabled = val),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Enable Biometric Authentication',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Use fingerprint/face for attendance',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: _isBiometricEnabled,
            onChanged: (val) => setState(() => _isBiometricEnabled = val),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
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
                child: CustomTextField(
                  label: 'Check-in Time',
                  hint: '09:00 AM',
                  controller: _checkInTimeController,
                  prefixIcon: Icons.login_rounded,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  label: 'Check-out Time',
                  hint: '06:00 PM',
                  controller: _checkOutTimeController,
                  prefixIcon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Working Hours (per day)',
                  hint: '8',
                  controller: _workingHoursController,
                  prefixIcon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  label: 'Break Duration (minutes)',
                  hint: '30',
                  controller: _breakDurationController,
                  prefixIcon: Icons.free_breakfast_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: Text(
                    'Check-in Required',
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  value: _isCheckInRequired,
                  onChanged: (val) => setState(() => _isCheckInRequired = val),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: Text(
                    'Check-out Required',
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  value: _isCheckOutRequired,
                  onChanged: (val) => setState(() => _isCheckOutRequired = val),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCard() {
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
          SwitchListTile(
            title: Text(
              'Allow Mobile Check-in',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Employees can check-in from mobile app',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Allow Remote Check-in',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Employees can check-in from outside office',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: false,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Send Email Notifications',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Notify HR on attendance changes',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: Text(
              'Auto-approve Leave',
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            subtitle: Text(
              'Auto-approve leave requests (for testing)',
              style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
            value: false,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showTimeZonePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                'Select Time Zone',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ..._timeZones.map((tz) => ListTile(
              title: Text(tz),
              trailing: _selectedTimeZone == tz
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedTimeZone = tz;
                });
                Navigator.pop(context);
              },
            )),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}