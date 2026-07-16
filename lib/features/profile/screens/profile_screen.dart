// ============================================================
// 📁 lib/features/profile/screens/profile_screen.dart
// ============================================================
// Role-based profile screen - Shows user info properly
// Employee can edit their profile
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../providers/profile_provider.dart';
import '../../admin/screens/office_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageBase64;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  void _loadProfileImage() async {
    final auth = context.read<AuthProvider>();
    final image = await auth.getProfileImage();
    if (mounted) {
      setState(() {
        _profileImageBase64 = image;
      });
    }
  }

  void _startEditing(AuthUser user) {
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _departmentController = TextEditingController(text: user.department);
    _designationController = TextEditingController(text: user.designation);

    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();

    await auth.updateCurrentUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
    );

    _cancelEditing();
    if (mounted) {
      AppHelpers.showSuccess(context, 'Profile updated successfully!');
    }
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

        final auth = context.read<AuthProvider>();
        await auth.updateProfileImage(base64Image);

        if (mounted) {
          setState(() {
            _profileImageBase64 = base64Image;
          });
          AppHelpers.showSuccess(context, 'Profile photo updated!');
        }
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

  // FIXED: Helper to convert base64 string to Uint8List
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, user),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD.w,
              vertical: AppDimensions.paddingMD.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isEditing)
                  _buildEditForm()
                else
                  _buildInfoCard(user),
                SizedBox(height: 20.h),

                 _sectionLabel('Account'),
                SizedBox(height: 8.h),
                _buildSettingsCard([
                  _SettingItem(Icons.account_balance_wallet_outlined, 'Leave Balance', AppColors.success, () {
                    Navigator.pushNamed(context, '/leave-balance');
                  }),
                ]),
                SizedBox(height: 20.h),

                if (isAdmin) ...[
                  _sectionLabel('Administration', isAdminSection: true),
                  SizedBox(height: 8.h),
                  _buildSettingsCard([
                    _SettingItem(
                      Icons.business,
                      'Company Settings',
                      AppColors.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OfficeSettingsScreen()),
                      ),
                    ),
                  ]),
                  SizedBox(height: 20.h),
                ],

                _buildLogoutButton(context, auth),
                SizedBox(height: 10.h),

                Center(
                  child: Text(
                    'HRMIS v1.0.0',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMD.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, size: 20.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined, size: 20.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: _departmentController,
            decoration: InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.business_outlined, size: 20.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: _designationController,
            decoration: InputDecoration(
              labelText: 'Designation',
              prefixIcon: Icon(Icons.work_outline, size: 20.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthUser? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 32.h,
        left: AppDimensions.paddingMD.w,
        right: AppDimensions.paddingMD.w,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 88.w,
            height: 88.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
            ),
            child: ClipOval(
              child: _profileImageBase64 != null && _profileImageBase64!.isNotEmpty
                  ? Image.memory(
                      _base64ToBytes(_profileImageBase64!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(user),
                    )
                  : _buildAvatarPlaceholder(user),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user?.name ?? 'User Name',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 6.h),
          Text(
            user?.designation.isNotEmpty == true ? user!.designation : (user?.email ?? 'user@company.com'),
            style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.85)),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppHelpers.getDepartmentIcon(user?.department ?? ''), size: 14.sp, color: Colors.white70),
                SizedBox(width: 6.w),
                Text(
                  user?.department.isNotEmpty == true ? user!.department : 'General Department',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(AuthUser? user) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          AppHelpers.getInitials(user?.name ?? 'U'),
          style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoCard(AuthUser? user) {
    final employeeId = user?.empCode.isNotEmpty == true ? user!.empCode : (user?.id ?? 'EMP001');
    
    String joiningDate = 'N/A';
    if (user?.joiningDate != null && user!.joiningDate!.isNotEmpty) {
      try {
        final parsed = DateTime.parse(user.joiningDate!);
        joiningDate = DateFormat('MMM yyyy').format(parsed);
      } catch (_) {
        joiningDate = user.joiningDate!;
      }
    }

    final empType = user?.employeeType ?? 'Permanent';

    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMD.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _InfoChip(Icons.badge_outlined, employeeId, 'Employee ID'),
          _InfoDivider(),
          _InfoChip(Icons.calendar_today, joiningDate, 'Joined'),
          _InfoDivider(),
          _InfoChip(Icons.work_outline, empType, 'Employee Type'),
        ],
      ),
    );
  }

  String _getJoiningDate(String? employeeId) {
    switch (employeeId) {
      case 'ADMIN001': return 'Jan 2023';
      case 'EMP001': return 'Jan 2023';
      case 'EMP002': return 'Mar 2023';
      case 'EMP003': return 'Jun 2023';
      case 'EMP004': return 'Sep 2023';
      default: return 'Jan 2024';
    }
  }

  Widget _sectionLabel(String label, {bool isAdminSection = false}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isAdminSection ? AppColors.primary : AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return _settingTile(items[i], i == items.length - 1);
        }),
      ),
    );
  }

  Widget _settingTile(_SettingItem item, bool isLast) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD.w, vertical: 14.h),
        decoration: isLast ? null : BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(item.icon, size: 20.sp, color: item.color),
            ),
            SizedBox(width: 14.w),
            Expanded(child: Text(item.label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout_rounded, color: AppColors.error, size: 30.sp),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Confirm Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to logout?\nYou will need to login again to access your account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          context.read<NavigationProvider>().reset();
          await auth.logout();
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Logout', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primary),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40.h, color: AppColors.border);
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SettingItem(this.icon, this.label, this.color, this.onTap);
}