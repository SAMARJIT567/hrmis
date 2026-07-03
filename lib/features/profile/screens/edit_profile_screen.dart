// ============================================================
// 📁 lib/features/profile/screens/edit_profile_screen.dart
// ============================================================
// Employee can edit their profile: name, email, department, designation, photo
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;

  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImageBase64;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _designationController = TextEditingController(text: user?.designation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        setState(() {
          _selectedImageBase64 = base64Image;
        });
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Failed to pick image');
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _imageOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _imageOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  if (_selectedImageBase64 != null)
                    Expanded(
                      child: _imageOption(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        color: AppColors.error,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedImageBase64 = null;
                          });
                        },
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Helper to convert base64 string to Uint8List
  Uint8List _base64ToBytes(String base64String) {
    try {
      // Remove data:image/jpeg;base64, prefix if present
      final base64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      // Decode base64 to Uint8List
      return base64Decode(base64);
    } catch (e) {
      // Return empty Uint8List if decoding fails
      return Uint8List(0);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();

    if (_selectedImageBase64 != null) {
      await profileProvider.updateProfileImage(_selectedImageBase64!);
    }

    await profileProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
    );

    if (mounted) {
      AppHelpers.showSuccess(context, 'Profile updated successfully!');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentImage = _selectedImageBase64 ?? profileProvider.profileImage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfilePhoto(currentImage),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please enter name' : null,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please enter email';
                        if (!val.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Department',
                      hint: 'Enter your department',
                      controller: _departmentController,
                      prefixIcon: Icons.business_outlined,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please enter department' : null,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Designation',
                      hint: 'Enter your designation',
                      controller: _designationController,
                      prefixIcon: Icons.work_outline,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please enter designation' : null,
                    ),
                    SizedBox(height: 24.h),
                    CustomButton(
                      label: 'Save Changes',
                      onPressed: _saveProfile,
                      prefixIcon: Icons.save_rounded,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePhoto(String? imageBase64) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageBase64 != null && imageBase64.isNotEmpty
                    ? Image.memory(
                        _base64ToBytes(imageBase64),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                      )
                    : _buildAvatarPlaceholder(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(
                    'Change Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final initials = AppHelpers.getInitials(_nameController.text);
    return Container(
      width: 100.w,
      height: 100.h,
      color: Colors.transparent,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}