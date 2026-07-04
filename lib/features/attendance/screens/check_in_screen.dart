// ============================================================
// 📁 lib/features/attendance/screens/check_in_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../../../core/constants/app_colors.dart';
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
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default to Delhi
  Set<Marker> _markers = {};
  
  bool _isLoading = true;
  bool _isWithinRange = false;
  double _distanceFromOffice = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // 1. Camera Init
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras![0],
        );
        _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
    }

    // 2. Location Init
    try {
      await _locationService.checkLocationServices();
      await _locationService.requestPermission();
      
      final locationData = await _locationService.getCurrentLocation();
      final settings = context.read<OfficeSettingsProvider>().settings;
      
      if (locationData['latitude'] != null) {
        _currentPosition = LatLng(locationData['latitude'], locationData['longitude']);
      }

      if (settings.latitude != 0) {
        _distanceFromOffice = _locationService.calculateDistance(
          lat1: _currentPosition.latitude,
          lon1: _currentPosition.longitude,
          lat2: settings.latitude,
          lon2: settings.longitude,
        ) * 1000;
        
        _isWithinRange = _distanceFromOffice <= settings.allowedRadiusMeters;
        _updateMarkers(settings);
      }
    } catch (e) {
      debugPrint('❌ Location error: $e');
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _updateMarkers(settings) {
    _markers = {
      Marker(
        markerId: const MarkerId('current'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('office'),
        position: LatLng(settings.latitude, settings.longitude),
      ),
    };
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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF1A237E), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check In',
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _buildCameraSection(),
                SizedBox(height: 20.h),
                _buildOfficeInfoCard(settings),
                SizedBox(height: 16.h),
                _buildMapSection(settings),
                SizedBox(height: 16.h),
                _buildDistanceIndicator(settings),
                SizedBox(height: 24.h),
                _buildSubmitButton(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isCameraInitialized && _cameraController != null)
              CameraPreview(_cameraController!)
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),
            Positioned(
              top: 12.r,
              right: 12.r,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 18.sp),
              ),
            ),
            Positioned(
              bottom: 12.r,
              right: 12.r,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  children: [
                    Icon(Icons.camera_front_rounded, color: Colors.white, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text('Front Camera', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeInfoCard(settings) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2962FF), Color(0xFF3D5AFE)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.business_rounded, color: Colors.white, size: 28.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(settings.officeName.isEmpty ? 'Office Not Set' : settings.officeName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                Text('Radius: ${settings.allowedRadiusMeters.toInt()} meters', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20.r)),
            child: Text(_isWithinRange ? 'INSIDE ZONE' : 'OUTSIDE ZONE', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700)),
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
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: GoogleMap(
          key: const ValueKey('attendance_map'),
          initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
          onMapCreated: (c) {
            _mapController = c;
            if(settings.latitude != 0) {
               _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(settings.latitude, settings.longitude)));
            }
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: true,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
          },
        ),
      ),
    );
  }

  Widget _buildDistanceIndicator(settings) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: const Color(0xFF00C853), size: 16.sp),
                  SizedBox(width: 4.w),
                  Text('Distance to Office:', style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54)),
                ],
              ),
              Text('${_distanceFromOffice.toInt()} / ${settings.allowedRadiusMeters.toInt()} m', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF00C853))),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: (settings.allowedRadiusMeters > 0) ? (_distanceFromOffice / settings.allowedRadiusMeters).clamp(0.0, 1.0) : 0.0,
              backgroundColor: Colors.black12,
              color: const Color(0xFF00C853),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(_isWithinRange ? Icons.check_box : Icons.error, color: const Color(0xFF00C853), size: 14.sp),
              SizedBox(width: 6.w),
              Text(_isWithinRange ? 'You are within office zone' : 'You are outside office zone', style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF00C853), fontWeight: FontWeight.w500)),
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
        onPressed: () async {
          if (!_isWithinRange) {
             AppHelpers.showError(context, 'You are outside the allowed zone');
             return;
          }
          final success = await context.read<EmployeeAttendanceProvider>().checkIn();
          if (success && mounted) {
            AppHelpers.showSuccess(context, 'Check-in successful!');
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.camera_alt, size: 20.sp),
        label: Text('Take Selfie & Submit', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
      ),
    );
  }
}
