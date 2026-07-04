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
import '../providers/leave_provider.dart';

class EmployeeLeaveRequest {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final double days;
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

class LeaveBalance {
  final String type;
  final int total;
  final int used;
  final Color color;
  final IconData icon;

  int get remaining => total - used;

  const LeaveBalance({
    required this.type,
    required this.total,
    required this.used,
    required this.color,
    required this.icon,
  });
}

class EmployeeLeaveProvider extends ChangeNotifier {
  List<EmployeeLeaveRequest> _requests = [];
  List<LeaveBalance> _balances = [
    const LeaveBalance(
      type: 'Casual Leave',
      total: 12,
      used: 4,
      color: AppColors.primary,
      icon: Icons.event_note_rounded,
    ),
    const LeaveBalance(
      type: 'Sick Leave',
      total: 10,
      used: 2,
      color: AppColors.error,
      icon: Icons.medical_services_rounded,
    ),
    const LeaveBalance(
      type: 'Earned Leave',
      total: 15,
      used: 5,
      color: AppColors.success,
      icon: Icons.beach_access_rounded,
    ),
    const LeaveBalance(
      type: 'Maternity Leave',
      total: 180,
      used: 0,
      color: AppColors.secondary,
      icon: Icons.pregnant_woman_rounded,
    ),
    const LeaveBalance(
      type: 'Paternity Leave',
      total: 15,
      used: 0,
      color: AppColors.accent,
      icon: Icons.child_care_rounded,
    ),
    const LeaveBalance(
      type: 'Comp. Off',
      total: 5,
      used: 1,
      color: AppColors.warning,
      icon: Icons.celebration_rounded,
    ),
    const LeaveBalance(
      type: 'Bereavement Leave',
      total: 5,
      used: 0,
      color: Color(0xFF475569),
      icon: Icons.heart_broken_rounded,
    ),
  ];
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<EmployeeLeaveRequest> get requests => _requests;
  List<LeaveBalance> get balances => _balances;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  int get pendingCount => _requests.where((r) => r.status == 'pending').length;
  int get approvedCount => _requests.where((r) => r.status == 'approved').length;
  int get rejectedCount => _requests.where((r) => r.status == 'rejected').length;
  int get totalLeaveBalance => _balances.fold(0, (sum, b) => sum + b.total);

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
        toDate: '26 May 2025', days: 2.0, reason: 'Family function',
        status: 'approved', appliedOn: '20 May 2025',
      ),
      const EmployeeLeaveRequest(
        id: '2', leaveType: 'Sick Leave', fromDate: '10 May 2025',
        toDate: '10 May 2025', days: 1.0, reason: 'Fever',
        status: 'approved', appliedOn: '09 May 2025',
      ),
      const EmployeeLeaveRequest(
        id: '3', leaveType: 'Earned Leave', fromDate: '01 Jun 2025',
        toDate: '05 Jun 2025', days: 5.0, reason: 'Vacation',
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
    double? customDays,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    final days = customDays ?? (toDate.difference(fromDate).inDays + 1).toDouble();

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeLeaveProvider()),
      ],
      child: Builder(
        builder: (context) => Scaffold(
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
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
            children: [
              _buildLeaveBalanceCard(),
              _buildStatsRow(),
              _buildApplyButton(context),
              _buildHistoryTitle(),
              _buildLeaveHistory(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard() {
    return Consumer<EmployeeLeaveProvider>(
      builder: (context, provider, __) {
        if (provider.isLoading || provider.balances.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Leave Balances',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.balances.length,
                itemBuilder: (context, index) {
                  final balance = provider.balances[index];
                  return Container(
                    width: 130.w,
                    margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: balance.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(balance.icon, color: balance.color, size: 14.sp),
                            ),
                            Text(
                              '${balance.total} T',
                              style: GoogleFonts.poppins(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          balance.type,
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${balance.remaining}',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: balance.color,
                              ),
                            ),
                            Text(
                              ' Left',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer<EmployeeLeaveProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
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

  Widget _buildApplyButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final provider = Provider.of<EmployeeLeaveProvider>(context, listen: false);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => ChangeNotifierProvider.value(
            value: provider,
            child: const LeaveApplySheet(),
          ),
        );
      },
      icon: Icon(Icons.add, size: 18.sp),
      label: Text('Apply Leave', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
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

class LeaveApplySheet extends StatefulWidget {
  const LeaveApplySheet({super.key});

  @override
  State<LeaveApplySheet> createState() => _LeaveApplySheetState();
}

class _LeaveApplySheetState extends State<LeaveApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String? _selectedLeaveType;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access global LeaveProvider to sync with Admin Panel
    final globalLeaveProvider = Provider.of<LeaveProvider>(context);
    final provider = Provider.of<EmployeeLeaveProvider>(context);
    
    final leaveTypes = globalLeaveProvider.policies.map((p) => p.title).toList();
    
    if (_selectedLeaveType == null && leaveTypes.isNotEmpty) {
      _selectedLeaveType = leaveTypes.first;
    }

        return Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Apply for Leave',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 20.h),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Leave Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Type',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLeaveType,
                                  isExpanded: true,
                                  hint: Text('Select Leave Type', style: GoogleFonts.poppins(fontSize: 14.sp)),
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                  items: leaveTypes.map((type) => DropdownMenuItem(
                                    value: type, 
                                    child: Text(type, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textPrimary))
                                  )).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedLeaveType = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // From Date
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
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
                              border: Border.all(color: AppColors.border),
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
                        // To Date
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _toDate,
                              firstDate: _fromDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                _toDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.border),
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
                        // Reason
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Reason for leave',
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textTertiary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Please enter reason' : null,
                        ),
                        SizedBox(height: 24.h),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (provider.isSubmitting || _selectedLeaveType == null) ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await provider.applyLeave(
                                  leaveType: _selectedLeaveType!,
                                  fromDate: _fromDate,
                                  toDate: _toDate,
                                  reason: _reasonController.text.trim(),
                                );
                                if (success && mounted) {
                                  Navigator.pop(context); // Close Bottom Sheet
                                  AppHelpers.showSuccess(context, 'Leave applied successfully!');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: provider.isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Submit Request', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}
