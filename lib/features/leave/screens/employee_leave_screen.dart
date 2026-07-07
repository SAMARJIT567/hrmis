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
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/leave_provider.dart';
import '../models/leave_model.dart';

// ─── DATA MODELS ─────────────────────────────────────────────

class EmployeeLeaveRequest {
  final String id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final double days;
  final String reason;
  final String status; // pending, approved, rejected, closed
  final String appliedOn;
  final String? medicalCertificate;
  final String? fitnessCertificate;
  final String? joiningDate;

  const EmployeeLeaveRequest({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.medicalCertificate,
    this.fitnessCertificate,
    this.joiningDate,
  });

  EmployeeLeaveRequest copyWith({
    String? status,
    String? fitnessCertificate,
    String? joiningDate,
  }) {
    return EmployeeLeaveRequest(
      id: id,
      leaveType: leaveType,
      fromDate: fromDate,
      toDate: toDate,
      days: days,
      reason: reason,
      status: status ?? this.status,
      appliedOn: appliedOn,
      medicalCertificate: medicalCertificate,
      fitnessCertificate: fitnessCertificate ?? this.fitnessCertificate,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
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

class CompOffCredit {
  final String id;
  final String dutyDate;
  final String expiryDate;
  final String reason;
  final String status; // pending, approved, used, lapsed
  final String attachment;

  const CompOffCredit({
    required this.id,
    required this.dutyDate,
    required this.expiryDate,
    required this.reason,
    required this.status,
    required this.attachment,
  });

  CompOffCredit copyWith({String? status}) {
    return CompOffCredit(
      id: id,
      dutyDate: dutyDate,
      expiryDate: expiryDate,
      reason: reason,
      status: status ?? this.status,
      attachment: attachment,
    );
  }
}

// ─── STATE MANAGEMENT ────────────────────────────────────────

class EmployeeLeaveProvider extends ChangeNotifier {
  final AuthUser? user;
  List<EmployeeLeaveRequest> _requests = [];
  List<CompOffCredit> _compOffCredits = [];
  List<LeavePolicy> _globalPolicies = [];
  
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<EmployeeLeaveRequest> get requests => _requests;
  List<CompOffCredit> get compOffCredits => _compOffCredits;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  void updateGlobalPolicies(List<LeavePolicy> policies) {
    _globalPolicies = policies;
    notifyListeners();
  }

  List<LeaveBalance> get balances {
    if (_globalPolicies.isEmpty) return [];

    return _globalPolicies.map((policy) {
      int total = policy.totalDays;

      // Compensatory Leave logic
      if (policy.id == 'CO') {
        total = _compOffCredits.where((c) => c.status == 'approved').length;
      }

      return LeaveBalance(
        type: policy.title,
        total: total,
        used: _calculateUsed(policy.title),
        color: Color(policy.colorValue),
        icon: AppHelpers.getLeaveIcon(policy.iconName),
      );
    }).toList();
  }

  int _calculateUsed(String type) {
    double count = 0;
    for (var r in _requests) {
      if (r.leaveType == type && (r.status == 'approved' || r.status == 'closed')) {
        count += r.days;
      }
    }
    return count.toInt();
  }

  int get pendingCount => _requests.where((r) => r.status == 'pending').length;
  int get approvedCount => _requests.where((r) => r.status == 'approved').length;
  int get rejectedCount => _requests.where((r) => r.status == 'rejected').length;

  EmployeeLeaveProvider({this.user}) {
    loadLeaveRequests();
  }

  bool isSecondOrFourthSaturday(DateTime date) {
    if (date.weekday != DateTime.saturday) return false;
    int day = date.day;
    return (day >= 8 && day <= 14) || (day >= 22 && day <= 28);
  }

  double calculateCLDuration(DateTime start, DateTime end, {bool isHalfDay = false}) {
    if (isHalfDay) return 0.5;
    int count = 0;
    for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      if (d.weekday != DateTime.sunday && !isSecondOrFourthSaturday(d)) {
        count++;
      }
    }
    return count.toDouble();
  }

  void updatePolicy(String id, int newTotal) {
    // This is handled by globalPolicies update now
  }

  Future<void> loadLeaveRequests() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _requests = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> applyLeave({required String leaveType, required DateTime fromDate, required DateTime toDate, required String reason, double? customDays}) async {
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

  Future<bool> logHolidayDuty({required DateTime dutyDate, required String reason, required String attachment}) async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    final expiryDate = dutyDate.add(const Duration(days: 30));
    final newCredit = CompOffCredit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dutyDate: DateFormat('dd MMM yyyy').format(dutyDate),
      expiryDate: DateFormat('dd MMM yyyy').format(expiryDate),
      reason: reason,
      status: 'approved',
      attachment: attachment,
    );

    _compOffCredits.insert(0, newCredit);
    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  Future<bool> submitJoiningReport({required String requestId, required String fitnessCertificate, required DateTime joiningDate}) async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: 'closed',
        fitnessCertificate: fitnessCertificate,
        joiningDate: DateFormat('dd MMM yyyy').format(joiningDate),
      );
    }

    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}

// ─── UI SCREENS ──────────────────────────────────────────────

class EmployeeLeaveScreen extends StatefulWidget {
  const EmployeeLeaveScreen({super.key});
  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final leaveProvider = Provider.of<LeaveProvider>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<LeaveProvider, EmployeeLeaveProvider>(
          create: (context) => EmployeeLeaveProvider(user: authProvider.currentUser),
          update: (context, leaveProv, employeeLeaveProv) {
            employeeLeaveProv!.updateGlobalPolicies(leaveProv.policies);
            return employeeLeaveProv;
          },
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Leave Management', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary), onPressed: () => Navigator.pop(context)) : null,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
            children: [
              _buildLeaveBalanceCard(),
              _buildStatsRow(),
              _buildActionButtons(context),
              _buildHistoryTitle(),
              _buildLeaveHistory(context),
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
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Leave Balances', style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${provider.balances.length} Types', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(
              height: 155.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.balances.length,
                itemBuilder: (context, index) {
                  final balance = provider.balances[index];
                  final progress = balance.total > 0 ? (balance.remaining / balance.total) : 0.0;
                  
                  return Container(
                    width: 130.w,
                    margin: EdgeInsets.only(right: 12.w, bottom: 10.h),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: balance.color.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: balance.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(balance.icon, color: balance.color, size: 18.sp),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${balance.remaining}', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w800, color: balance.color, height: 1.1)),
                                Text('Days', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(balance.type, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: balance.color.withOpacity(0.1),
                            color: balance.color,
                            minHeight: 5.h,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${balance.total}', style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 9.sp, color: balance.color, fontWeight: FontWeight.w700)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 2))]),
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

  Widget _buildActionButtons(BuildContext context) {
    final provider = Provider.of<EmployeeLeaveProvider>(context, listen: false);
    return ElevatedButton.icon(
      onPressed: () => showModalBottomSheet(
        context: context, 
        isScrollControlled: true, 
        backgroundColor: Colors.transparent, 
        builder: (ctx) => ChangeNotifierProvider.value(
          value: provider, 
          child: const LeaveApplySheet()
        )
      ),
      icon: Icon(Icons.add, size: 18.sp),
      label: Text('Apply Leave', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, 
        foregroundColor: Colors.white, 
        minimumSize: Size(double.infinity, 48.h), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))
      ),
    );
  }

  Widget _statItem(String label, int count, Color color) => Expanded(child: Column(children: [Text('$count', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: color)), Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary))]));
  Widget _statDivider() => Container(width: 1, height: 30.h, color: AppColors.border);

  Widget _buildHistoryTitle() => Padding(padding: EdgeInsets.only(top: 16.h, bottom: 8.h), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Leave History', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), Text('Recent requests', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textTertiary))]));

  Widget _buildLeaveHistory(BuildContext context) {
    return Consumer<EmployeeLeaveProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const Center(child: InlineLoader());
        if (provider.requests.isEmpty) return const EmptyStateWidget(icon: Icons.event_busy_rounded, title: 'No Leave Requests', subtitle: 'Your leave history will appear here.');
        return Column(children: provider.requests.map((request) => _buildHistoryCard(context, request, provider)).toList());
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, EmployeeLeaveRequest request, EmployeeLeaveProvider provider) {
    final statusColor = request.status == 'approved' ? AppColors.success : request.status == 'pending' ? AppColors.warning : request.status == 'closed' ? Colors.blueGrey : AppColors.error;
    final statusBg = request.status == 'approved' ? AppColors.successLight : request.status == 'pending' ? AppColors.warningLight : request.status == 'closed' ? Colors.blueGrey.withOpacity(0.1) : AppColors.errorLight;

    bool needsJoiningReport = false;
    if (request.status == 'approved' && (request.leaveType == 'Commuted Leave' || request.leaveType == 'Half Pay Leave')) {
      try {
        final toDate = DateFormat('dd MMM yyyy').parse(request.toDate);
        if (DateTime.now().isAfter(toDate)) needsJoiningReport = true;
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(request.leaveType, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12.r)), child: Text(request.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: statusColor))),
            ],
          ),
          SizedBox(height: 6.h),
          Text('${request.fromDate} - ${request.toDate} (${request.days % 1 == 0 ? request.days.toInt() : request.days} day${request.days > 1 ? 's' : ''})', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary)),
          if (request.reason.isNotEmpty) Padding(padding: EdgeInsets.only(top: 4.h), child: Text(request.reason, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textTertiary))),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Applied on: ${request.appliedOn}', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textHint)),
              if (needsJoiningReport)
                ElevatedButton(
                  onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => ChangeNotifierProvider.value(value: provider, child: JoiningReportSheet(request: request))),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 12.w), minimumSize: Size(0, 28.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                  child: Text('Submit Joining', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                ),
              if (request.status == 'closed') Row(children: [Icon(Icons.check_circle_outline_rounded, color: Colors.blueGrey, size: 14.sp), SizedBox(width: 4.w), Text('Joined on: ${request.joiningDate}', style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.blueGrey, fontWeight: FontWeight.w500))]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BOTTOM SHEETS ───────────────────────────────────────────

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
  bool _isHalfDay = false;
  bool _isToDateSelected = false;
  String _halfDaySession = 'Forenoon';
  bool _isMiscarriage = false;
  DateTime? _deliveryDate;
  String? _uploadedFileName;

  double _calculateCurrentDays(EmployeeLeaveProvider provider) {
    if (_selectedLeaveType == 'Casual Leave') return provider.calculateCLDuration(_fromDate, _toDate, isHalfDay: _isHalfDay);
    final from = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final to = DateTime(_toDate.year, _toDate.month, _toDate.day);
    return _isHalfDay ? 0.5 : (to.difference(from).inDays + 1).toDouble();
  }

  String? _validateCasualLeaveRules(DateTime from, DateTime to, List<EmployeeLeaveRequest> requests, EmployeeLeaveProvider provider) {
    if (_selectedLeaveType != 'Casual Leave') return null;
    final days = provider.calculateCLDuration(from, to, isHalfDay: _isHalfDay);
    if (days > 5) return 'Casual Leave can only be applied for a maximum of 5 days as per Govt rules.';
    final dateFormat = DateFormat('dd MMM yyyy');
    for (var req in requests) {
      if ((req.status == 'approved' || req.status == 'pending') && (req.leaveType == 'Earned Leave' || req.leaveType == 'Commuted Leave' || req.leaveType == 'Half Pay Leave')) {
        try {
          final reqFrom = dateFormat.parse(req.fromDate);
          final reqTo = dateFormat.parse(req.toDate);
          if (dateFormat.format(from.subtract(const Duration(days: 1))) == dateFormat.format(reqTo) || dateFormat.format(to.add(const Duration(days: 1))) == dateFormat.format(reqFrom)) {
            return 'Casual Leave (CL) cannot be taken just before or after regular leave.';
          }
        } catch (_) {}
      }
    }
    return null;
  }

  String? _validateHalfPayLeaveRules(DateTime from, DateTime to, AuthUser? user, List<LeaveBalance> balances) {
    if (_selectedLeaveType != 'Half Pay Leave') return null;
    final days = (to.difference(from).inDays + 1).toDouble();
    final hplBalance = balances.firstWhere((b) => b.type == 'Half Pay Leave');
    if (hplBalance.remaining < days) return 'Insufficient Half Pay Leave (HPL) balance.';
    return null;
  }

  String? _validateCommutedLeaveRules(DateTime from, DateTime to, AuthUser? user, List<LeaveBalance> balances, List<EmployeeLeaveRequest> requests) {
    if (_selectedLeaveType != 'Commuted Leave') return null;
    final days = (to.difference(from).inDays + 1).toDouble();
    final hplBalance = balances.firstWhere((b) => b.type == 'Half Pay Leave');
    if (hplBalance.remaining < (days * 2)) return 'Insufficient HPL balance (Needs 2 HPL for 1 Commuted Day).';
    return null;
  }

  String? _validateMaternityLeaveRules(AuthUser? user) {
    if (_selectedLeaveType != 'Maternity Leave') return null;
    if (user == null || user.gender != 'Female') return 'Applicable for Female employees only.';
    if (user.survivingChildren >= 2 && !_isMiscarriage) return 'Maternity Leave is only for the first two surviving children.';
    return null;
  }

  String? _validatePaternityLeaveRules(DateTime start, AuthUser? user) {
    if (_selectedLeaveType != 'Paternity Leave') return null;
    if (user == null || user.gender != 'Male') return 'Applicable for Male employees only.';
    if (user.survivingChildren >= 2) return 'Paternity Leave is only for the first two surviving children.';
    if (_deliveryDate == null) return 'Please select the Delivery Date.';
    final minDate = _deliveryDate!.subtract(const Duration(days: 15));
    final maxDate = _deliveryDate!.add(const Duration(days: 180));
    if (start.isBefore(minDate) || start.isAfter(maxDate)) return 'Paternity Leave must be taken within 15 days before or 6 months after delivery.';
    return null;
  }

  String? _validateCompensatoryLeaveRules(DateTime from, DateTime to, List<CompOffCredit> credits) {
    if (_selectedLeaveType != 'Compensatory Leave') return null;
    final days = (to.difference(from).inDays + 1).toDouble();
    if (days > 2) return 'Max 2 days of Compensatory Leave allowed at a time.';
    final dateFormat = DateFormat('dd MMM yyyy');
    bool hasValidCredit = credits.any((c) => c.status == 'approved' && !from.isAfter(dateFormat.parse(c.expiryDate)));
    if (!hasValidCredit) return 'No valid Compensatory credit found (Expiry 30 days).';
    return null;
  }

  String? _validateEarnedLeaveRules(DateTime from, DateTime to, AuthUser? user, List<EmployeeLeaveRequest> requests) {
    if (_selectedLeaveType != 'Earned Leave') return null;
    if (from.isBefore(DateTime.now().add(const Duration(days: 15)))) return 'Apply for EL at least 15 days in advance.';
    return null;
  }

  void _showPolicyAlert(BuildContext context, String message) {
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), title: Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28.sp), SizedBox(width: 10.w), Text('Policy Alert', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.error))]), content: Text(message, style: GoogleFonts.poppins(fontSize: 14.sp)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)))]));
  }

  @override
  void dispose() { _reasonController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final globalLeaveProvider = Provider.of<LeaveProvider>(context);
    final provider = Provider.of<EmployeeLeaveProvider>(context);
    final authUser = Provider.of<AuthProvider>(context).currentUser;
    List<String> leaveTypes = globalLeaveProvider.policies.map((p) => p.title).toList();
    if (authUser?.gender != 'Female') leaveTypes.removeWhere((t) => t.contains('Maternity'));
    if (authUser?.gender != 'Male') leaveTypes.removeWhere((t) => t.contains('Paternity'));
    if (_selectedLeaveType == null && leaveTypes.isNotEmpty) _selectedLeaveType = leaveTypes.first;

    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.75, maxHeight: MediaQuery.of(context).size.height * 0.95),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 30.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            Text('Apply for Leave', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 20.h),
            if (provider.isLoading) const Center(child: CircularProgressIndicator())
            else Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildLeaveTypeDropdown(leaveTypes, globalLeaveProvider),
                  _buildRulesBox(),
                  if (_selectedLeaveType == 'Casual Leave') _buildHalfDayToggle(),
                  if (_selectedLeaveType == 'Maternity Leave') _buildMiscarriageToggle(),
                  if (_selectedLeaveType == 'Paternity Leave') _buildDeliveryDatePicker(),
                  if (_selectedLeaveType == 'Compensatory Leave') _buildLogDutyButton(provider),
                  if (_selectedLeaveType != 'Paternity Leave') _buildDatePickers(),
                  _buildUploadSection(),
                  _buildDurationDisplay(provider),
                  _buildReasonField(),
                  SizedBox(height: 24.h),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeDropdown(List<String> leaveTypes, LeaveProvider global) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Leave Type', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      SizedBox(height: 6.h),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLeaveType, isExpanded: true, items: leaveTypes.map((type) => DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textPrimary)))).toList(),
              onChanged: (value) => setState(() {
                _selectedLeaveType = value;
                _isMiscarriage = false;
                _isToDateSelected = (_selectedLeaveType == 'Maternity Leave' || _selectedLeaveType == 'Paternity Leave');
                if (_selectedLeaveType == 'Maternity Leave') _toDate = _fromDate.add(const Duration(days: 179));
                if (_selectedLeaveType == 'Paternity Leave') _toDate = _fromDate.add(const Duration(days: 14));
                if (_selectedLeaveType == 'Compensatory Leave' || _selectedLeaveType == 'Commuted Leave' || _selectedLeaveType == 'Half Pay Leave' || _selectedLeaveType == 'Earned Leave' || _selectedLeaveType == 'Maternity Leave' || _selectedLeaveType == 'Paternity Leave') {
                  _isHalfDay = false;
                }
              }),
          ),
        ),
      ),
    ]);
  }

  Widget _buildRulesBox() {
    String rules = '';
    Color color = AppColors.primary;
    if (_selectedLeaveType == 'Casual Leave') {
      rules = '• FREE DAYS: Sundays and 2nd/4th Saturdays are NOT counted.\n• HALF DAY: Counted as 0.5 Day (Approx. 4 Hours).\n• LIMIT: Max 5 days allowed in one go.\n• BACK-TO-BACK: Do not take EL/Medical leave just before or after CL.';
    } else if (_selectedLeaveType == 'Earned Leave') {
      rules = '• TOTAL: 30 days added every year (15 in Jan, 15 in July).\n• HOLIDAYS: Sundays/Holidays during your leave ARE counted.\n• MAXIMUM: You can save up to 300 days total.\n• APPLY EARLY: Please apply 15 days before your leave starts.';
      color = AppColors.success;
    } else if (_selectedLeaveType == 'Commuted Leave') {
      rules = '• PAY: Full Salary during medical leave.\n• DURATION: 1 Day = 8 Hours (Deducts 2 HPL days).\n• CERTIFICATE: Medical Certificate mandatory from Day 1.\n• JOINING: Upload Fitness Certificate via "Submit Joining" button on History card.';
      color = AppColors.error;
    } else if (_selectedLeaveType == 'Half Pay Leave') {
      rules = '• SALARY: You get only HALF Pay (50%) for these days.\n• DEDUCTION: 1 Day Leave = 1 Day minus from HPL account.\n• LIMIT: No max limit; depends on balance.\n• UPLOAD: No documents required for personal work.';
      color = AppColors.warning;
    } else if (_selectedLeaveType == 'Compensatory Leave') {
      rules = '• EARNING: Earned by working on Public Holidays/Sundays.\n• EXPIRY: Must be used within 30 days of duty.\n• LIMIT: Maximum 2 days allowed at a time.\n• NO HALF DAY: Only full day leave is allowed.';
      color = AppColors.warning;
    } else if (_selectedLeaveType == 'Maternity Leave') {
      rules = '• ELIGIBILITY: Female employees with < 2 children.\n• DURATION: 180 days (6 months) continuous block.\n• SALARY: Full Pay during leave period.\n• EXTENSION: Up to 60 days extra leave (EL/HPL) allowed.';
      color = AppColors.secondary;
    } else if (_selectedLeaveType == 'Paternity Leave') {
      rules = '• ELIGIBILITY: Male employees with < 2 children.\n• DURATION: 15 days continuous block (Full Pay).\n• AUTOMATIC: Leave dates are auto-calculated from Delivery Date.\n• UPLOAD: Birth Certificate mandatory.';
      color = AppColors.accent;
    }
    if (rules.isEmpty) return const SizedBox.shrink();
    return Container(margin: EdgeInsets.only(top: 12.h), padding: EdgeInsets.all(12.r), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: color.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.info_outline_rounded, color: color, size: 16.sp), SizedBox(width: 8.w), Text('$_selectedLeaveType Rules', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color))]), SizedBox(height: 4.h), Text(rules, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textPrimary.withOpacity(0.8), height: 1.5))]));
  }

  Widget _buildHalfDayToggle() => Padding(padding: EdgeInsets.only(top: 12.h), child: Row(children: [SizedBox(height: 24.w, width: 24.w, child: Checkbox(value: _isHalfDay, activeColor: AppColors.primary, onChanged: (v) => setState(() { _isHalfDay = v ?? false; if (_isHalfDay) _toDate = _fromDate; }))), SizedBox(width: 8.w), Text('Half Day', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500)), if (_isHalfDay) ...[SizedBox(width: 20.w), Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: AppColors.border)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _halfDaySession, isDense: true, items: ['Forenoon', 'Afternoon'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 12.sp)))).toList(), onChanged: (v) => setState(() => _halfDaySession = v!)))))]]));
  Widget _buildMiscarriageToggle() => Padding(padding: EdgeInsets.only(top: 12.h), child: Row(children: [Checkbox(value: _isMiscarriage, activeColor: AppColors.secondary, onChanged: (v) => setState(() { _isMiscarriage = v ?? false; _toDate = _fromDate.add(Duration(days: _isMiscarriage ? 44 : 179)); })), SizedBox(width: 8.w), Text('Case of Miscarriage/Abortion (Max 45 Days)', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500))]));

  Widget _buildDeliveryDatePicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 16.h), Text('Date of Delivery', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)), SizedBox(height: 6.h), GestureDetector(onTap: () async { final p = await showDatePicker(context: context, initialDate: _deliveryDate ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 200)), lastDate: DateTime.now().add(const Duration(days: 30))); if (p != null) setState(() { _deliveryDate = p; _fromDate = p; _toDate = p.add(const Duration(days: 14)); _isToDateSelected = true; }); }, child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(Icons.event_available_rounded, size: 18.sp, color: AppColors.accent), SizedBox(width: 12.w), Text(_deliveryDate == null ? 'Select Delivery Date' : DateFormat('dd MMM yyyy').format(_deliveryDate!), style: GoogleFonts.poppins(fontSize: 13.sp))])) )]);

  Widget _buildDatePickers() => Column(children: [
    SizedBox(height: 16.h),
    GestureDetector(onTap: () async { final p = await showDatePicker(context: context, initialDate: _fromDate, firstDate: (_selectedLeaveType == 'Commuted Leave' || _selectedLeaveType == 'Half Pay Leave') ? DateTime.now().subtract(const Duration(days: 90)) : DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (p != null) setState(() { _fromDate = p; if (_toDate.isBefore(p)) { _toDate = p; _isToDateSelected = false; } }); }, child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(Icons.calendar_today, size: 18.sp, color: AppColors.primary), SizedBox(width: 12.w), Text('From: ${DateFormat('dd MMM yyyy').format(_fromDate)}', style: GoogleFonts.poppins(fontSize: 13.sp))]))),
    if (!_isHalfDay) ...[SizedBox(height: 12.h), GestureDetector(onTap: () async { final p = await showDatePicker(context: context, initialDate: _toDate, firstDate: _fromDate, lastDate: DateTime.now().add(const Duration(days: 365))); if (p != null) setState(() { _toDate = p; _isToDateSelected = true; }); }, child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(Icons.calendar_today, size: 18.sp, color: AppColors.primary), SizedBox(width: 12.w), Text('To: ${DateFormat('dd MMM yyyy').format(_toDate)}', style: GoogleFonts.poppins(fontSize: 13.sp))])))]
  ]);

  Widget _buildUploadSection() {
    bool needed = (_selectedLeaveType == 'Commuted Leave' || _selectedLeaveType == 'Maternity Leave' || _selectedLeaveType == 'Paternity Leave');
    if (!needed) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 16.h),
      Text('Attachment (Mandatory)', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      SizedBox(height: 6.h),
      GestureDetector(onTap: () async { final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']); if (r != null) setState(() => _uploadedFileName = r.files.first.name); }, child: Container(width: double.infinity, padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: _uploadedFileName == null ? AppColors.error.withOpacity(0.5) : AppColors.success.withOpacity(0.5))), child: Row(children: [Icon(_uploadedFileName == null ? Icons.picture_as_pdf_outlined : Icons.check_circle_rounded, color: _uploadedFileName == null ? AppColors.error : AppColors.success, size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(_uploadedFileName ?? 'Upload PDF (Max 5MB)', style: GoogleFonts.poppins(fontSize: 13.sp, color: _uploadedFileName == null ? AppColors.textTertiary : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis))]))),
    ]);
  }

  Widget _buildDurationDisplay(EmployeeLeaveProvider provider) {
    if (!_isHalfDay && !_isToDateSelected) return const SizedBox.shrink();
    final days = _calculateCurrentDays(provider);
    return Padding(padding: EdgeInsets.symmetric(vertical: 16.h), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text('Total Duration: ', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)), Text('$days day${days != 1 ? 's' : ''}', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primary)), Text(' (Approx. ${(days * 8).toInt()} Hours)', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.secondary))]), if (_selectedLeaveType == 'Casual Leave' && !_isHalfDay) Text('* Sundays & 2nd/4th Saturdays excluded.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.success, fontStyle: FontStyle.italic))]));
  }

  Widget _buildReasonField() => TextFormField(controller: _reasonController, maxLines: 2, decoration: InputDecoration(hintText: 'Reason for leave', filled: true, fillColor: AppColors.surfaceVariant, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary))), validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a valid reason' : null);

  Widget _buildLogDutyButton(EmployeeLeaveProvider provider) {
    final approvedCredits = provider.compOffCredits.where((c) => c.status == 'approved').toList();
    
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approvedCredits.isNotEmpty) ...[
            Text(
              'Available Approved Credits',
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.success),
            ),
            SizedBox(height: 8.h),
            ...approvedCredits.map((c) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.verified_rounded, color: AppColors.success, size: 14.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duty: ${c.dutyDate}', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                        Text(c.reason, style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Valid Until', style: GoogleFonts.poppins(fontSize: 8.sp, color: AppColors.textHint)),
                      Text(c.expiryDate, style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            )).toList(),
            SizedBox(height: 8.h),
          ],
          Text(
            'Step 1: Credit your duty (if not listed above)',
            style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context, 
              isScrollControlled: true, 
              backgroundColor: Colors.transparent, 
              builder: (ctx) => ChangeNotifierProvider.value(
                value: provider, 
                child: const LogHolidayDutySheet()
              )
            ),
            icon: Icon(Icons.history_edu_rounded, size: 16.sp),
            label: Text('Log Holiday Duty Now', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              minimumSize: Size(double.infinity, 44.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Step 2: Select the leave dates below',
            style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(EmployeeLeaveProvider provider) => SizedBox(
    width: double.infinity, 
    child: ElevatedButton(
      onPressed: provider.isSubmitting ? null : () async { 
        if (_formKey.currentState!.validate()) { 
          final days = _calculateCurrentDays(provider);
          final effectiveToDate = _isHalfDay ? _fromDate : _toDate;

          // 1. Casual Leave
          final clError = _validateCasualLeaveRules(_fromDate, effectiveToDate, provider.requests, provider);
          if (clError != null) { _showPolicyAlert(context, clError); return; }

          // 2. Commuted Leave
          final commError = _validateCommutedLeaveRules(_fromDate, effectiveToDate, provider.user, provider.balances, provider.requests);
          if (commError != null) { _showPolicyAlert(context, commError); return; }

          // 3. Half Pay Leave
          final hplError = _validateHalfPayLeaveRules(_fromDate, effectiveToDate, provider.user, provider.balances);
          if (hplError != null) { _showPolicyAlert(context, hplError); return; }

          // 4. Earned Leave
          final elError = _validateEarnedLeaveRules(_fromDate, effectiveToDate, provider.user, provider.requests);
          if (elError != null) { _showPolicyAlert(context, elError); return; }

          // 5. Maternity Leave
          final mlError = _validateMaternityLeaveRules(provider.user);
          if (mlError != null) { _showPolicyAlert(context, mlError); return; }

          // 6. Paternity Leave
          final plError = _validatePaternityLeaveRules(_fromDate, provider.user);
          if (plError != null) { _showPolicyAlert(context, plError); return; }

          // 7. Compensatory Leave
          final compError = _validateCompensatoryLeaveRules(_fromDate, effectiveToDate, provider.compOffCredits);
          if (compError != null) { _showPolicyAlert(context, compError); return; }

          // Attachment Check
          if ((_selectedLeaveType == 'Commuted Leave' || _selectedLeaveType == 'Maternity Leave' || _selectedLeaveType == 'Paternity Leave') && _uploadedFileName == null) { 
            _showPolicyAlert(context, 'Attachment is mandatory.'); 
            return; 
          } 

          if (await provider.applyLeave(
            leaveType: _selectedLeaveType!, 
            fromDate: _fromDate, 
            toDate: effectiveToDate, 
            reason: _reasonController.text.trim() +
                    (_isHalfDay ? ' (Half Day - $_halfDaySession)' : ''), 
            customDays: days
          )) { 
            if (mounted) {
              Navigator.pop(context); 
              AppHelpers.showSuccess(context, 'Request submitted!');
            }
          } 
        } 
      }, 
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), 
      child: provider.isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Submit Details', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))
    )
  );
}

class JoiningReportSheet extends StatefulWidget {
  final EmployeeLeaveRequest request;
  const JoiningReportSheet({super.key, required this.request});
  @override
  State<JoiningReportSheet> createState() => _JoiningReportSheetState();
}

class _JoiningReportSheetState extends State<JoiningReportSheet> {
  DateTime _joiningDate = DateTime.now();
  String? _fitnessFileName;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeLeaveProvider>(context, listen: false);
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5, maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 30.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            Text('Joining Report & Fitness', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text('Leave: ${widget.request.leaveType}', style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 24.h),
            _buildDatePicker(),
            SizedBox(height: 20.h),
            _buildFilePicker(),
            SizedBox(height: 32.h),
            _buildSubmitButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Actual Joining Date', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)), SizedBox(height: 8.h), GestureDetector(onTap: () async { final p = await showDatePicker(context: context, initialDate: _joiningDate, firstDate: DateFormat('dd MMM yyyy').parse(widget.request.toDate), lastDate: DateTime.now().add(const Duration(days: 7))); if (p != null) setState(() => _joiningDate = p); }, child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(Icons.calendar_today_rounded, size: 18.sp, color: AppColors.primary), SizedBox(width: 12.w), Text(DateFormat('dd MMMM yyyy').format(_joiningDate), style: GoogleFonts.poppins(fontSize: 14.sp))])) )]);
  Widget _buildFilePicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Fitness Certificate', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)), SizedBox(height: 8.h), GestureDetector(onTap: () async { final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']); if (r != null) setState(() => _fitnessFileName = r.files.first.name); }, child: Container(width: double.infinity, padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: _fitnessFileName == null ? AppColors.error.withOpacity(0.3) : AppColors.success.withOpacity(0.3))), child: Row(children: [Icon(_fitnessFileName == null ? Icons.upload_file_rounded : Icons.check_circle_rounded, color: _fitnessFileName == null ? AppColors.error : AppColors.success, size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(_fitnessFileName ?? 'Upload Certificate', style: GoogleFonts.poppins(fontSize: 13.sp, color: _fitnessFileName == null ? AppColors.textTertiary : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis))])) )]);
  Widget _buildSubmitButton(EmployeeLeaveProvider p) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isSubmitting ? null : () async { if (_fitnessFileName == null) { AppHelpers.showError(context, 'Upload certificate first'); return; } setState(() => _isSubmitting = true); if (await p.submitJoiningReport(requestId: widget.request.id, fitnessCertificate: _fitnessFileName!, joiningDate: _joiningDate)) { Navigator.pop(context); AppHelpers.showSuccess(context, 'Leave Closed!'); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text('Submit Joining Report', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))));
}

class LogHolidayDutySheet extends StatefulWidget {
  const LogHolidayDutySheet({super.key});
  @override
  State<LogHolidayDutySheet> createState() => _LogHolidayDutySheetState();
}

class _LogHolidayDutySheetState extends State<LogHolidayDutySheet> {
  DateTime _dutyDate = DateTime.now();
  final _reasonController = TextEditingController();
  String? _attachmentName;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeLeaveProvider>(context, listen: false);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 30.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            Text('Log Holiday Duty', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 24.h),
            _buildDatePicker(),
            SizedBox(height: 16.h),
            _buildReasonField(),
            SizedBox(height: 16.h),
            _buildFilePicker(),
            SizedBox(height: 24.h),
            _buildSubmitButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() => GestureDetector(onTap: () async { final p = await showDatePicker(context: context, initialDate: _dutyDate, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now()); if (p != null) setState(() => _dutyDate = p); }, child: Container(padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(Icons.calendar_month_rounded, size: 18.sp, color: AppColors.primary), SizedBox(width: 12.w), Text('Date of Duty: ${DateFormat('dd MMM yyyy').format(_dutyDate)}', style: GoogleFonts.poppins(fontSize: 13.sp))])));
  Widget _buildReasonField() => TextFormField(controller: _reasonController, maxLines: 2, decoration: InputDecoration(hintText: 'Duty details...', filled: true, fillColor: AppColors.surfaceVariant, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary))));
  Widget _buildFilePicker() => GestureDetector(onTap: () async { final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']); if (r != null) setState(() => _attachmentName = r.files.first.name); }, child: Container(width: double.infinity, padding: EdgeInsets.all(14.r), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: _attachmentName == null ? AppColors.error.withOpacity(0.3) : AppColors.success.withOpacity(0.3))), child: Row(children: [Icon(_attachmentName == null ? Icons.upload_file_rounded : Icons.check_circle_rounded, color: _attachmentName == null ? AppColors.error : AppColors.success, size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(_attachmentName ?? 'Attach Written Order (PDF)', style: GoogleFonts.poppins(fontSize: 13.sp, color: _attachmentName == null ? AppColors.textTertiary : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis))])));
  Widget _buildSubmitButton(EmployeeLeaveProvider p) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isSubmitting ? null : () async { if (_attachmentName == null || _reasonController.text.isEmpty) { AppHelpers.showError(context, 'Missing details'); return; } setState(() => _isSubmitting = true); if (await p.logHolidayDuty(dutyDate: _dutyDate, reason: _reasonController.text.trim(), attachment: _attachmentName!)) { Navigator.pop(context); AppHelpers.showSuccess(context, 'Duty Logged!'); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text('Submit Duty Report', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))));
}
