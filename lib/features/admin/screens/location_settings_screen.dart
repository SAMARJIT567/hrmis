// ============================================================
// 📁 lib/features/admin/screens/location_settings_screen.dart
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/loading_widget.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _zones = [];
  List<dynamic> _employees = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _api.getZones(all: true),
        _api.getEmployees(),
      ]);

      final zoneData = results[0];
      final empData = results[1];

      setState(() {
        if (zoneData.containsKey('zones')) {
          _zones = zoneData['zones'] as List<dynamic>;
        }
        if (empData.containsKey('data')) {
          _employees = empData['data'] as List<dynamic>;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isUserInZone(dynamic user, dynamic zoneId) {
    final rawZoneIds = user['zone_ids'];
    if (rawZoneIds == null) return false;

    final targetStr = zoneId.toString().trim();
    if (targetStr.isEmpty) return false;

    List<String> ids = [];

    if (rawZoneIds is List) {
      ids = rawZoneIds.map((e) => e.toString().trim()).toList();
    } else {
      // Clean string of brackets, quotes, and escape slashes robustly
      final cleaned = rawZoneIds.toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('\\', '')
          .replaceAll('"', '')
          .replaceAll("'", '')
          .trim();
      
      if (cleaned.isEmpty) return false;
      ids = cleaned.split(',').map((e) => e.trim()).toList();
    }

    return ids.contains(targetStr);
  }

  List<dynamic> _getEmployeesForZone(dynamic zoneId) {
    return _employees.where((emp) => _isUserInZone(emp, zoneId)).toList();
  }

  List<dynamic> _parseCoordinates(dynamic coords) {
    if (coords == null) return [];
    if (coords is List) return coords;
    if (coords is String) {
      try {
        return json.decode(coords) as List<dynamic>;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Location Settings',
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
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadLocations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: InlineLoader(size: 32))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48.sp, color: AppColors.error),
                        SizedBox(height: 16.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _loadLocations,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _zones.isEmpty
                  ? Center(
                      child: Text(
                        'No configured locations found.',
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.r),
                      itemCount: _zones.length,
                      itemBuilder: (context, index) {
                        final zone = _zones[index];
                        final name = zone['name'] as String? ?? 'Unnamed Zone';
                        final officeType = zone['office_type'] as String? ?? 'Office';
                        final status = zone['status'] as String? ?? 'active';
                        final ssid = zone['ssid'] as String? ?? 'N/A';
                        final bssid = zone['bssid'] as String? ?? 'N/A';
                        final wifiCheck = zone['wifi_check'] as String? ?? 'No';
                        final coordsList = _parseCoordinates(zone['coordinates']);

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  officeType.toLowerCase() == 'park'
                                      ? Icons.park_outlined
                                      : Icons.business_outlined,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: officeType.toLowerCase() == 'park'
                                            ? Colors.green.withOpacity(0.1)
                                            : AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100.r),
                                      ),
                                      child: Text(
                                        officeType.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w700,
                                          color: officeType.toLowerCase() == 'park'
                                              ? Colors.green
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() == 'active'
                                            ? AppColors.success.withOpacity(0.1)
                                            : AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100.r),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w700,
                                          color: status.toLowerCase() == 'active'
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                const Divider(color: AppColors.border, height: 1),
                                Padding(
                                  padding: EdgeInsets.all(16.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('WiFi Check Required', wifiCheck),
                                      _buildInfoRow('WiFi SSID Name', ssid),
                                      _buildInfoRow('WiFi Router BSSID', bssid),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'Geofence Boundary (${coordsList.length} Corners)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      if (coordsList.isEmpty)
                                        Text(
                                          'No geofence coordinates configured.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(12.r),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          padding: EdgeInsets.all(12.r),
                                          child: Column(
                                            children: List.generate(coordsList.length, (idx) {
                                              final pt = coordsList[idx];
                                              final lat = pt['lat'] ?? pt['latitude'];
                                              final lng = pt['lng'] ?? pt['longitude'];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 20.r,
                                                      height: 20.r,
                                                      alignment: Alignment.center,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        '${idx + 1}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10.sp,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Expanded(
                                                      child: Text(
                                                        'Lat: $lat\nLng: $lng',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10.sp,
                                                          fontWeight: FontWeight.w500,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Assigned Employees',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Builder(
                                        builder: (context) {
                                          final zoneEmployees = _getEmployeesForZone(zone['id']);
                                          if (zoneEmployees.isEmpty) {
                                            return Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius: BorderRadius.circular(12.r),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.people_outline_rounded, size: 16.sp, color: AppColors.textTertiary),
                                                  SizedBox(width: 10.w),
                                                  Text(
                                                    'No employees assigned to this location',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: AppColors.textTertiary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius: BorderRadius.circular(12.r),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<dynamic>(
                                                isExpanded: true,
                                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20.sp),
                                                hint: Row(
                                                  children: [
                                                    Icon(Icons.people_alt_outlined, size: 16.sp, color: AppColors.primary),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      '${zoneEmployees.length} Employee(s) Assigned',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                items: zoneEmployees.map<DropdownMenuItem<dynamic>>((emp) {
                                                  final empName = emp['name'] as String? ?? 'Unnamed';
                                                  final empDept = emp['department'] as String? ?? 'N/A';
                                                  final empDesg = emp['designation'] as String? ?? 'N/A';

                                                  return DropdownMenuItem<dynamic>(
                                                    value: emp,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 6.r,
                                                          height: 6.r,
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.primary,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                empName,
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 11.sp,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: AppColors.textPrimary,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              Text(
                                                                '$empDesg • $empDept',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 9.sp,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: AppColors.textSecondary,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (_) {},
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
