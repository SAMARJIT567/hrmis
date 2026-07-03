// ============================================================
// 📁 lib/core/services/camera_service.dart
// ============================================================
// Service for handling camera operations
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  // ─── Singleton Pattern ─────────────────────────────────────
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  // ─── State ──────────────────────────────────────────────────
  bool _isCameraAvailable = false;
  bool _isPermissionGranted = false;

  bool get isCameraAvailable => _isCameraAvailable;
  bool get isPermissionGranted => _isPermissionGranted;

  // ─── Check Camera Availability ─────────────────────────────
  Future<bool> checkCameraAvailability() async {
    try {
      // Simulate checking camera
      await Future.delayed(const Duration(milliseconds: 300));
      _isCameraAvailable = true;
      return _isCameraAvailable;
    } catch (e) {
      debugPrint('❌ Camera check failed: $e');
      _isCameraAvailable = false;
      return false;
    }
  }

  // ─── Request Camera Permission ────────────────────────────
  Future<bool> requestCameraPermission() async {
    try {
      // Simulate permission request
      await Future.delayed(const Duration(milliseconds: 500));
      _isPermissionGranted = true;
      return _isPermissionGranted;
    } catch (e) {
      debugPrint('❌ Camera permission request failed: $e');
      _isPermissionGranted = false;
      return false;
    }
  }

  // ─── Take Photo from Camera ──────────────────────────────
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Take photo failed: $e');
      return null;
    }
  }

  // ─── Pick Image from Gallery ──────────────────────────────
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Pick image from gallery failed: $e');
      return null;
    }
  }

  // ─── Pick Multiple Images ──────────────────────────────────
  Future<List<File>> pickMultipleImages({int maxCount = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('❌ Pick multiple images failed: $e');
      return [];
    }
  }

  // ─── Convert File to Base64 ──────────────────────────────
  Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return 'data:image/jpeg;base64,${String.fromCharCodes(bytes)}';
    } catch (e) {
      debugPrint('❌ File to base64 failed: $e');
      return null;
    }
  }

  // ─── Compress Image ─────────────────────────────────────────
  Future<File> compressImage({
    required File image,
    int targetSizeKB = 200,
  }) async {
    try {
      // Simulate compression
      await Future.delayed(const Duration(milliseconds: 500));
      return image; // Return original for now
    } catch (e) {
      debugPrint('❌ Image compression failed: $e');
      return image;
    }
  }

  // ─── Get Image Thumbnail ────────────────────────────────────
  Future<File?> getThumbnail(File image, {int width = 200, int height = 200}) async {
    try {
      // Simulate thumbnail generation
      await Future.delayed(const Duration(milliseconds: 300));
      return image; // Return original for now
    } catch (e) {
      debugPrint('❌ Get thumbnail failed: $e');
      return null;
    }
  }
}