// ============================================================
// 📁 lib/core/services/location_service.dart
// ============================================================
// Service for handling actual location operations using geolocator
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> checkLocationServices() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;
    
    return true;
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': 'Current Location', // Reverse geocoding can be added with geocoding package
      };
    } catch (e) {
      debugPrint('❌ Failed to get location: $e');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': 'Unknown Location',
      };
    }
  }

  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // Returns distance in KM
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
