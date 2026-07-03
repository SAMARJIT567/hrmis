// ============================================================
// 📁 lib/features/employees/screens/add_employee_screen.dart
// ============================================================
// Screen to add new employee with all details
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _profileImageBase64;

  // ─── Controllers ──────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _employeeTypeController = TextEditingController();

  // ─── Dropdown Values ──────────────────────────────────────────
  String _selectedDepartment = 'Engineering';
  String _selectedDesignation = 'Software Developer';
  String _selectedGender = 'Male';
  String _selectedEmployeeType = 'Full-time';
  String _selectedStatus = 'active';

  final List<String> _departments = [
    'Engineering',
    'HR',
    'Finance',
    'Marketing',
    'Design',
    'Sales',
    'Operations',
    'Legal',
  ];

  final List<String> _designations = [
    'Software Developer',
    'Senior Developer',
    'Team Lead',
    'Project Manager',
    'HR Manager',
    'HR Executive',
    'Finance Manager',
    'Accounts Manager',
    'Marketing Lead',
    'Marketing Executive',
    'UI/UX Designer',
    'Graphic Designer',
    'Sales Executive',
    'Sales Manager',
    'Operations Manager',
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _employeeTypes = ['Full-time', 'Part-time', 'Contract', 'Intern'];
  final List<String> _statuses = ['active', 'inactive'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _joiningDateController.dispose();
    _genderController.dispose();
    _employeeTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        setState(() {
          _profileImage = imageFile;
          _profileImageBase64 = 'data:image/jpeg;base64,${String.fromCharCodes(bytes)}';
        });
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Failed to pick image');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text = AppHelpers.formatDate(picked);
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final employee = Employee(
      id: 'EMP${DateTime.now().millisecondsSinceEpoch}'.substring(0, 8),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment,
      designation: _selectedDesignation,
      employeeType: _selectedEmployeeType,
      status: _selectedStatus,
      joiningDate: _joiningDateController.text.trim(),
      salary: double.tryParse(_salaryController.text.trim()) ?? 0,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      leaveBalance: 12,
      avatarUrl: _profileImageBase64,
    );

    context.read<EmployeeProvider>().addEmployee(employee);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      AppHelpers.showSuccess(context, 'Employee added successfully!');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Add Employee',
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
            onPressed: _saveEmployee,
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
                    // ─── Profile Photo ──────────────────────────
                    _buildProfilePhoto(),
                    SizedBox(height: 20.h),

                    // ─── Personal Information ──────────────────
                    _sectionTitle('Personal Information'),
                    SizedBox(height: 10.h),
                    _buildPersonalInfoCard(),
                    SizedBox(height: 16.h),

                    // ─── Work Information ──────────────────────
                    _sectionTitle('Work Information'),
                    SizedBox(height: 10.h),
                    _buildWorkInfoCard(),
                    SizedBox(height: 16.h),

                    // ─── Additional Information ─────────────────
                    _sectionTitle('Additional Information'),
                    SizedBox(height: 10.h),
                    _buildAdditionalInfoCard(),
                    SizedBox(height: 24.h),

                    // ─── Save Button ────────────────────────────
                    CustomButton(
                      label: 'Add Employee',
                      onPressed: _saveEmployee,
                      prefixIcon: Icons.person_add_rounded,
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

  Widget _buildProfilePhoto() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySurface,
                border: Border.all(color: AppColors.primary, width: 2),
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImage == null
                  ? Icon(
                      Icons.camera_alt,
                      size: 30.sp,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _pickImage,
            child: Text(
              _profileImage == null ? 'Add Photo' : 'Change Photo',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
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
            label: 'Full Name *',
            hint: 'Enter employee full name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter name' : null,
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Email Address *',
            hint: 'Enter email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter email';
              if (!val.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Phone Number *',
            hint: 'Enter phone number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (val) =>
                val == null || val.isEmpty ? 'Please enter phone number' : null,
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Address',
            hint: 'Enter address',
            controller: _addressController,
            maxLines: 2,
            prefixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoCard() {
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
          _buildDropdownField(
            label: 'Department *',
            value: _selectedDepartment,
            items: _departments,
            icon: Icons.business_outlined,
            onChanged: (val) => setState(() => _selectedDepartment = val!),
            validator: (val) => val == null ? 'Please select department' : null,
          ),
          SizedBox(height: 12.h),
          _buildDropdownField(
            label: 'Designation *',
            value: _selectedDesignation,
            items: _designations,
            icon: Icons.work_outline,
            onChanged: (val) => setState(() => _selectedDesignation = val!),
            validator: (val) => val == null ? 'Please select designation' : null,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Salary *',
                  hint: 'Enter salary (₹)',
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee_rounded,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter salary';
                    if (double.tryParse(val) == null) return 'Enter valid salary';
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdownField(
                  label: 'Employee Type',
                  value: _selectedEmployeeType,
                  items: _employeeTypes,
                  icon: Icons.category_outlined,
                  onChanged: (val) => setState(() => _selectedEmployeeType = val!),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18.sp, color: AppColors.primary),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            _joiningDateController.text.isEmpty
                                ? 'Joining Date *'
                                : _joiningDateController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: _joiningDateController.text.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdownField(
                  label: 'Status',
                  value: _selectedStatus,
                  items: _statuses,
                  icon: Icons.circle_outlined,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
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
          _buildDropdownField(
            label: 'Gender',
            value: _selectedGender,
            items: _genders,
            icon: Icons.wc_rounded,
            onChanged: (val) => setState(() => _selectedGender = val!),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            label: 'Leave Balance',
            hint: 'Initial leave balance',
            controller: TextEditingController(text: '12'),
            prefixIcon: Icons.event_available_rounded,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp, color: AppColors.primary),
          border: InputBorder.none,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(fontSize: 13.sp),
      ),
    );
  }
}