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
import '../../attendance/providers/office_settings_provider.dart';
import 'package:provider/provider.dart';

class OfficeSettingsScreen extends StatefulWidget {
  const OfficeSettingsScreen({super.key});

  @override
  State<OfficeSettingsScreen> createState() => _OfficeSettingsScreenState();
}

class _OfficeSettingsScreenState extends State<OfficeSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ────────────────────────────────────────────
  final _officeNameController = TextEditingController();
  final _officeAddressController = TextEditingController();
  final _officeLatitudeController = TextEditingController();
  final _officeLongitudeController = TextEditingController();
  final _checkInTimeController = TextEditingController();
  final _checkOutTimeController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _breakDurationController = TextEditingController();

  // ─── State ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isCheckInRequired = true;
  bool _isCheckOutRequired = true;
  bool _isLocationTrackingEnabled = true;
  double _allowedRadius = 100.0;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<OfficeSettingsProvider>().settings;
      setState(() {
        _allowedRadius = settings.allowedRadiusMeters;
        _officeNameController.text = settings.officeName;
        _officeAddressController.text = settings.officeAddress;
        _officeLatitudeController.text = settings.latitude.toString();
        _officeLongitudeController.text = settings.longitude.toString();
        _checkInTimeController.text = settings.checkInTime;
        _checkOutTimeController.text = settings.checkOutTime;
        _workingHoursController.text = settings.workingHoursPerDay.toString();
        _breakDurationController.text = settings.breakDurationMinutes.toString();
        _isCheckInRequired = settings.isCheckInRequired;
        _isCheckOutRequired = settings.isCheckOutRequired;
        _isLocationTrackingEnabled = settings.isLocationTrackingEnabled;
        _selectedTimeZone = settings.timeZone;
      });
    });
  }

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

    final provider = context.read<OfficeSettingsProvider>();
    final currentSettings = provider.settings;

    final updatedSettings = currentSettings.copyWith(
      officeName: _officeNameController.text,
      officeAddress: _officeAddressController.text,
      latitude: double.tryParse(_officeLatitudeController.text) ?? currentSettings.latitude,
      longitude: double.tryParse(_officeLongitudeController.text) ?? currentSettings.longitude,
      checkInTime: _checkInTimeController.text,
      checkOutTime: _checkOutTimeController.text,
      workingHoursPerDay: int.tryParse(_workingHoursController.text) ?? currentSettings.workingHoursPerDay,
      breakDurationMinutes: int.tryParse(_breakDurationController.text) ?? currentSettings.breakDurationMinutes,
      isCheckInRequired: _isCheckInRequired,
      isCheckOutRequired: _isCheckOutRequired,
      isLocationTrackingEnabled: _isLocationTrackingEnabled,
      timeZone: _selectedTimeZone,
      allowedRadiusMeters: _allowedRadius,
    );

    provider.updateSettings(updatedSettings);
    await provider.saveSettings();

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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location Radius',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_allowedRadius.toStringAsFixed(0)} meters',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      value: _allowedRadius,
                      min: 50,
                      max: 1000,
                      divisions: 19, // (1000-50)/50 = 19 divisions of 50m each
                      label: '${_allowedRadius.toStringAsFixed(0)}m',
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withOpacity(0.2),
                      onChanged: (value) {
                        setState(() {
                          _allowedRadius = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    'Allowed check-in radius from the office location',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
        ),
      ),
    );
  }

  void _showTimeZonePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      builder: (_) => SafeArea(
        child: Material(
          color: Colors.transparent,
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
      ),
    );
  }
}
