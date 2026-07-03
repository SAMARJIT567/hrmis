// ============================================================
// 📁 lib/features/attendance/screens/check_in_screen.dart
// ============================================================
// Actual Check-in screen with Live Camera Feed and Google Maps
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/helpers.dart';
import '../providers/office_settings_provider.dart';
import '../providers/employee_attendance_provider.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final LocationService _locationService = LocationService();
  
  // ─── Camera ──────────────────────────────────────────────────
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // ─── Map ─────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  Set<Marker> _markers = {};
  
  // ─── State ──────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isWithinRange = false;
  double _distanceFromOffice = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    setState(() => _isLoading = true);
    
    // 1. Initialize Camera
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Find front camera
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras![0],
        );
        
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
    }

    // 2. Initialize Location & Range
    await _locationService.checkLocationServices();
    await _locationService.requestPermission();
    
    final locationData = await _locationService.getCurrentLocation();
    final settings = context.read<OfficeSettingsProvider>().settings;
    
    _currentPosition = LatLng(
      locationData['latitude'] ?? 0.0,
      locationData['longitude'] ?? 0.0,
    );

    _distanceFromOffice = _locationService.calculateDistance(
      lat1: _currentPosition.latitude,
      lon1: _currentPosition.longitude,
      lat2: settings.latitude,
      lon2: settings.longitude,
    ) * 1000; // to meters
    
    _isWithinRange = _distanceFromOffice <= settings.allowedRadiusMeters;
    
    _updateMarkers(settings);
    
    setState(() => _isLoading = false);

    if (!_isWithinRange) {
      _showOutsideRangePopup();
    }
  }

  void _updateMarkers(settings) {
    _markers = {
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('office_location'),
        position: LatLng(settings.latitude, settings.longitude),
        infoWindow: InfoWindow(title: settings.officeName),
      ),
    };
  }

  void _showOutsideRangePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Column(
          children: [
            Icon(Icons.location_off_rounded, color: AppColors.error, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Outside Range',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Kindly go to the office location.\nYou are currently ${(_distanceFromOffice).toStringAsFixed(0)}m away from the office.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OfficeSettingsProvider>().settings;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check In',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                // ─── Camera Preview ────────────────────────────
                _buildCameraSection(),
                SizedBox(height: 20.h),

                // ─── Office Info Card ──────────────────────────
                _buildOfficeInfoCard(settings),
                SizedBox(height: 16.h),

                // ─── Google Map ───────────────────────────────
                _buildMapSection(settings),
                SizedBox(height: 16.h),

                // ─── Distance Indicator ────────────────────────
                _buildDistanceIndicator(settings),
                SizedBox(height: 24.h),

                // ─── Submit Button ─────────────────────────────
                _buildSubmitButton(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      height: 280.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: _isCameraInitialized && _cameraController != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController!),
                  _buildCameraOverlay(),
                ],
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 16.r,
          right: 16.r,
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20.sp),
          ),
        ),
        Positioned(
          bottom: 16.r,
          right: 16.r,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_front_rounded, color: Colors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  'Front Camera',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficeInfoCard(settings) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.business_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.officeName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Radius: ${settings.allowedRadiusMeters.toStringAsFixed(0)} meters',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              _isWithinRange ? 'INSIDE ZONE' : 'OUTSIDE ZONE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(settings) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          circles: {
            Circle(
              circleId: const CircleId('office_radius'),
              center: LatLng(settings.latitude, settings.longitude),
              radius: settings.allowedRadiusMeters,
              fillColor: AppColors.primary.withOpacity(0.1),
              strokeColor: AppColors.primary.withOpacity(0.5),
              strokeWidth: 2,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildDistanceIndicator(settings) {
    double progress = (_distanceFromOffice / settings.allowedRadiusMeters).clamp(0.0, 1.0);
    if (!_isWithinRange) progress = 1.0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.success, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Distance to Office:',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${_distanceFromOffice.toStringAsFixed(0)} / ${settings.allowedRadiusMeters.toStringAsFixed(0)} m',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _isWithinRange ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            color: _isWithinRange ? AppColors.success : AppColors.error,
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                _isWithinRange ? Icons.check_box_rounded : Icons.warning_rounded,
                color: _isWithinRange ? AppColors.success : AppColors.error,
                size: 14.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                _isWithinRange ? 'You are within office zone' : 'You are outside office zone',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: _isWithinRange ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isWithinRange ? () async {
          final provider = context.read<EmployeeAttendanceProvider>();
          final success = await provider.checkIn();
          if (success && mounted) {
            AppHelpers.showSuccess(context, 'Check-in completed successfully!');
            Navigator.pop(context);
          }
        } : () {
          _showOutsideRangePopup();
        },
        icon: Icon(Icons.camera_alt_rounded, size: 20.sp),
        label: Text(
          'Take Selfie & Submit',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isWithinRange ? AppColors.success : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 2,
        ),
      ),
    );
  }
}
