// ============================================================
// 📁 lib/core/services/location_service.dart
// ============================================================
// Service for handling location-related operations
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';

class LocationService {
  // ─── Singleton Pattern ─────────────────────────────────────
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // ─── State ──────────────────────────────────────────────────
  bool _isServiceEnabled = false;
  bool _isPermissionGranted = false;
  String? _currentAddress;
  double? _currentLatitude;
  double? _currentLongitude;

  bool get isServiceEnabled => _isServiceEnabled;
  bool get isPermissionGranted => _isPermissionGranted;
  String? get currentAddress => _currentAddress;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  // ─── Check if Location Services are Enabled ──────────────
  Future<bool> checkLocationServices() async {
    // Simulate checking location services
    await Future.delayed(const Duration(milliseconds: 300));
    _isServiceEnabled = true;
    return _isServiceEnabled;
  }

  // ─── Request Location Permission ─────────────────────────
  Future<bool> requestPermission() async {
    // Simulate requesting permission
    await Future.delayed(const Duration(milliseconds: 500));
    _isPermissionGranted = true;
    return _isPermissionGranted;
  }

  // ─── Get Current Location ──────────────────────────────────
  Future<Map<String, dynamic>> getCurrentLocation() async {
    // Simulate getting location
    await Future.delayed(const Duration(milliseconds: 800));
    _currentLatitude = 28.6139;
    _currentLongitude = 77.2090;
    _currentAddress = 'New Delhi, India';
    return {
      'latitude': _currentLatitude,
      'longitude': _currentLongitude,
      'address': _currentAddress,
    };
  }

  // ─── Get Address from Coordinates ──────────────────────────
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Simulate reverse geocoding
    await Future.delayed(const Duration(milliseconds: 600));
    return 'Near Connaught Place, New Delhi, India';
  }

  // ─── Calculate Distance between two coordinates ──────────
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  // ✅ FIXED: Helper Methods using dart:math
  double _toRadians(double degree) => degree * pi / 180;
  
  double _sin(double value) => sin(value);
  
  double _cos(double value) => cos(value);
  
  double _sqrt(double value) => sqrt(value);
  
  double _atan2(double a, double b) => atan2(a, b);

  // ─── Check if User is within Office Range ──────────────────
  Future<bool> isWithinOfficeRange({
    required double officeLatitude,
    required double officeLongitude,
    double rangeInMeters = 100,
  }) async {
    final location = await getCurrentLocation();
    if (location['latitude'] == null || location['longitude'] == null) {
      return false;
    }
    final distance = calculateDistance(
      lat1: location['latitude']!,
      lon1: location['longitude']!,
      lat2: officeLatitude,
      lon2: officeLongitude,
    );
    return distance * 1000 <= rangeInMeters;
  }
}