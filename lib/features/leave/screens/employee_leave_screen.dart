// ============================================================
// 📁 lib/features/leave/screens/employee_leave_screen.dart
// ============================================================
// Leave Screen - NO BOTTOM NAVIGATION (Parent se milega)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';

class EmployeeLeaveRequest {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  final String status;
  final String appliedOn;

  const EmployeeLeaveRequest({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedOn,
  });
}

class EmployeeLeaveProvider extends ChangeNotifier {
  List<EmployeeLeaveRequest> _requests = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<EmployeeLeaveRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  int get pendingCount => _requests.where((r) => r.status == 'pending').length;
  int get approvedCount => _requests.where((r) => r.status == 'approved').length;
  int get rejectedCount => _requests.where((r) => r.status == 'rejected').length;
  int get totalLeaveBalance => 12;

  EmployeeLeaveProvider() {
    loadLeaveRequests();
  }

  Future<void> loadLeaveRequests() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    _requests = [
      const EmployeeLeaveRequest(
        id: '1', leaveType: 'Casual Leave', fromDate: '25 May 2025',
        toDate: '26 May 2025', days: 2, reason: 'Family function',
        status: 'approved', appliedOn: '20 May 2025',
      ),
      const EmployeeLeaveRequest(
        id: '2', leaveType: 'Sick Leave', fromDate: '10 May 2025',
        toDate: '10 May 2025', days: 1, reason: 'Fever',
        status: 'approved', appliedOn: '09 May 2025',
      ),
      const EmployeeLeaveRequest(
        id: '3', leaveType: 'Earned Leave', fromDate: '01 Jun 2025',
        toDate: '05 Jun 2025', days: 5, reason: 'Vacation',
        status: 'pending', appliedOn: '25 May 2025',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> applyLeave({
    required String leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    final days = toDate.difference(fromDate).inDays + 1;

    final newRequest = EmployeeLeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      leaveType: leaveType,
      fromDate: DateFormat('dd MMM yyyy').format(fromDate),
      toDate: DateFormat('dd MMM yyyy').format(toDate),
      days: days,
      reason: reason,
      status: 'pending',
      appliedOn: DateFormat('dd MMM yyyy').format(DateTime.now()),
    );

    _requests.insert(0, newRequest);
    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}

class EmployeeLeaveScreen extends StatefulWidget {
  const EmployeeLeaveScreen({super.key});

  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  bool _showApplyForm = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeLeaveProvider()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Leave Management',
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
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          children: [
            _buildLeaveBalanceCard(),
            _buildStatsRow(),
            _buildApplyButton(),
            _buildHistoryTitle(),
            _buildLeaveHistory(),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard() {
    return Consumer<EmployeeLeaveProvider>(
      builder: (_, provider, __) {
        final usedLeaves = provider.approvedCount;
        final balance = provider.totalLeaveBalance - usedLeaves;

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave Balance', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                    Text('$balance days', style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Available', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white70)),
                  ],
                ),
              ),
              Container(width: 1, height: 50.h, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: Column(
                  children: [
                    Text('Used', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                    Text('$usedLeaves days', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
              Container(width: 1, height: 50.h, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: Column(
                  children: [
                    Text('Total', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70)),
                    Text('${provider.totalLeaveBalance} days', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer<EmployeeLeaveProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              _statItem('Pending', provider.pendingCount, AppColors.warning),
              _statDivider(),
              _statItem('Approved', provider.approvedCount, AppColors.success),
              _statDivider(),
              _statItem('Rejected', provider.rejectedCount, AppColors.error),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplyButton() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showApplyForm = !_showApplyForm;
            });
          },
          icon: Icon(_showApplyForm ? Icons.close : Icons.add, size: 18.sp),
          label: Text(_showApplyForm ? 'Cancel' : 'Apply Leave'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        if (_showApplyForm) ...[
          SizedBox(height: 12.h),
          _buildApplyForm(),
        ],
      ],
    );
  }

  Widget _buildApplyForm() {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController();
    String _selectedLeaveType = 'Casual Leave';
    DateTime _fromDate = DateTime.now();
    DateTime _toDate = DateTime.now();
    final List<String> _leaveTypes = ['Casual Leave', 'Sick Leave', 'Earned Leave'];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: StatefulBuilder(
        builder: (context, formSetState) {
          return Consumer<EmployeeLeaveProvider>(
            builder: (_, provider, __) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLeaveType,
                          isExpanded: true,
                          items: _leaveTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (value) {
                            formSetState(() {
                              _selectedLeaveType = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fromDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          formSetState(() {
                            _fromDate = picked;
                            if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18.sp, color: AppColors.primary),
                            SizedBox(width: 12.w),
                            Text('From: ${DateFormat('dd MMM yyyy').format(_fromDate)}', style: GoogleFonts.poppins(fontSize: 13.sp)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _toDate,
                          firstDate: _fromDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          formSetState(() {
                            _toDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18.sp, color: AppColors.primary),
                            SizedBox(width: 12.w),
                            Text('To: ${DateFormat('dd MMM yyyy').format(_toDate)}', style: GoogleFonts.poppins(fontSize: 13.sp)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Reason for leave',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter reason' : null,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSubmitting ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await provider.applyLeave(
                              leaveType: _selectedLeaveType,
                              fromDate: _fromDate,
                              toDate: _toDate,
                              reason: _reasonController.text.trim(),
                            );
                            if (success && context.mounted) {
                              _reasonController.clear();
                              setState(() {
                                _showApplyForm = false;
                              });
                              AppHelpers.showSuccess(context, 'Leave applied successfully!');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: provider.isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Submit Request', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 30.h, color: AppColors.border);

  Widget _buildHistoryTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Leave History', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Recent requests', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return Consumer<EmployeeLeaveProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: InlineLoader());
        }
        if (provider.requests.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.event_busy_rounded,
            title: 'No Leave Requests',
            subtitle: 'Your leave history will appear here.',
          );
        }
        return Column(
          children: provider.requests.map((request) => _buildHistoryCard(request)).toList(),
        );
      },
    );
  }

  Widget _buildHistoryCard(EmployeeLeaveRequest request) {
    final statusColor = request.status == 'approved' ? AppColors.success : request.status == 'pending' ? AppColors.warning : AppColors.error;
    final statusBg = request.status == 'approved' ? AppColors.successLight : request.status == 'pending' ? AppColors.warningLight : AppColors.errorLight;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request.leaveType, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12.r)),
                child: Text(request.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text('${request.fromDate} - ${request.toDate} (${request.days} day${request.days > 1 ? 's' : ''})', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary)),
          if (request.reason.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(request.reason, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary)),
          ],
          SizedBox(height: 4.h),
          Text('Applied on: ${request.appliedOn}', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textHint)),
        ],
      ),
    );
  }
}