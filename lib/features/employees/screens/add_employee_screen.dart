// ============================================================
// 📁 lib/features/employees/screens/add_employee_screen.dart
// ============================================================
// Screen to add new employee with UI matching the provided design.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../providers/employee_provider.dart';
import '../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────────
  final _empIdController = TextEditingController(text: 'EMP');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _dobController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // ─── Dropdown Values ──────────────────────────────────────────
  String _selectedDepartment = 'Engineering';
  String _selectedDesignation = 'Software Developer';
  String _selectedEmployeeType = 'Full-time';
  String _selectedStatus = 'active';
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';

  final List<String> _departments = ['Engineering', 'HR', 'Finance', 'Marketing', 'Design', 'Sales', 'Operations'];
  final List<String> _designations = ['Software Developer', 'Senior Developer', 'Team Lead', 'Project Manager', 'HR Manager', 'UI/UX Designer'];
  final List<String> _employeeTypes = ['Full-time', 'Part-time', 'Contract', 'Intern'];
  final List<String> _statuses = ['active', 'inactive'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _empIdController.addListener(_onEmpIdChanged);
  }

  void _onEmpIdChanged() {
    if (!_empIdController.text.startsWith('EMP')) {
      _empIdController.text = 'EMP';
      _empIdController.selection = TextSelection.fromPosition(
        TextPosition(offset: _empIdController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _empIdController.removeListener(_onEmpIdChanged);
    _empIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _joiningDateController.dispose();
    _dobController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = AppHelpers.formatDate(picked);
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      AppHelpers.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final employee = Employee(
      id: _empIdController.text.isEmpty 
          ? 'EMP${DateTime.now().millisecondsSinceEpoch}'.substring(0, 8)
          : _empIdController.text,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment,
      designation: _selectedDesignation,
      employeeType: _selectedEmployeeType,
      status: _selectedStatus,
      joiningDate: _joiningDateController.text,
      salary: double.tryParse(_salaryController.text) ?? 0,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      leaveBalance: 12,
    );

    context.read<EmployeeProvider>().addEmployee(employee);
    setState(() => _isLoading = false);

    if (mounted) {
      AppHelpers.showSuccess(context, 'Employee added successfully!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF1E3A8A), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Employee',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        
                        // ─── Basic Information ──────────────────────
                        _sectionHeader(Icons.person_outline_rounded, 'Basic Information'),
                        _buildLabel('Employee ID'),
                        _buildTextField(
                          hint: 'Enter ID (e.g., 001)',
                          controller: _empIdController,
                          icon: Icons.badge_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty || v == 'EMP') {
                              return 'Employee ID is required';
                            }
                            final employees = context.read<EmployeeProvider>().allEmployees;
                            final exists = employees.any((e) => e.id.toUpperCase() == v.toUpperCase());
                            if (exists) {
                              return 'Try different id this id existing';
                            }
                            return null;
                          },
                        ),
                        _buildLabel('Full Name *'),
                        _buildTextField(
                          hint: 'Enter employee full name',
                          controller: _nameController,
                          icon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Name is required' : null,
                        ),
                        _buildLabel('Email Address *'),
                        _buildTextField(
                          hint: 'Enter email address',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          validator: (v) => v!.isEmpty ? 'Email is required' : null,
                        ),
                        _buildLabel('Password *'),
                        _buildTextField(
                          hint: 'Enter password (min 6 characters)',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        _buildLabel('Confirm Password *'),
                        _buildTextField(
                          hint: 'Re-enter password',
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirmPassword,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20.sp, color: Colors.grey),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // ─── Contact Information ──────────────────────
                        _sectionHeader(Icons.contact_mail_outlined, 'Contact Information'),
                        _buildLabel('Phone Number *'),
                        _buildTextField(
                          hint: 'Enter phone number',
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildLabel('Address'),
                        _buildTextField(
                          hint: 'Enter complete address',
                          controller: _addressController,
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),

                        SizedBox(height: 24.h),

                        // ─── Professional Information ──────────────────
                        _sectionHeader(Icons.work_outline_rounded, 'Professional Information'),
                        _buildDateTile('Joining Date *', _joiningDateController),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown(_selectedDepartment, _departments, (v) => setState(() => _selectedDepartment = v!))),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildDropdown(_selectedDesignation, _designations, (v) => setState(() => _selectedDesignation = v!))),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown(_selectedEmployeeType, _employeeTypes, (v) => setState(() => _selectedEmployeeType = v!))),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildTextField(
                                hint: 'Salary *',
                                controller: _salaryController,
                                icon: Icons.currency_rupee_rounded,
                                keyboardType: TextInputType.number,
                                hideShadow: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown(_selectedStatus, _statuses, (v) => setState(() => _selectedStatus = v!))),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildDropdown(_selectedGender, _genders, (v) => setState(() => _selectedGender = v!))),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // ─── Additional Information ──────────────────
                        _sectionHeader(Icons.info_outline_rounded, 'Additional Information'),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown(_selectedBloodGroup, _bloodGroups, (v) => setState(() => _selectedBloodGroup = v!))),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildDateTile('Date of Birth', _dobController, icon: Icons.cake_outlined)),
                          ],
                        ),
                        _buildLabel('Emergency Contact Name'),
                        _buildTextField(
                          hint: 'Enter emergency contact person name',
                          controller: _emergencyNameController,
                          icon: Icons.person_outline,
                        ),
                        _buildLabel('Emergency Contact Number'),
                        _buildTextField(
                          hint: 'Enter emergency contact number',
                          controller: _emergencyPhoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
              
              // ─── Bottom Add Button ──────────────────────────
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_rounded, size: 20.sp),
                        SizedBox(width: 10.w),
                        Text('Add Employee', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF1E3A8A)),
          SizedBox(width: 8.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 10.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool hideShadow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, size: 18.sp, color: const Color(0xFF94A3B8)),
          suffixIcon: suffix,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
          style: GoogleFonts.poppins(fontSize: 14.sp, color: const Color(0xFF1E293B)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, TextEditingController controller, {IconData icon = Icons.calendar_today_rounded}) {
    return GestureDetector(
      onTap: () => _selectDate(controller),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: const Color(0xFF1E3A8A)),
            SizedBox(width: 10.w),
            Text(
              controller.text.isEmpty ? label : controller.text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: controller.text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
