// ============================================================
// 📁 lib/features/leave/models/leave_model.dart
// ─────────────────────────────────────────────────────────────
// Leave request data model.
// ============================================================

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final double days;
  final String reason;
  final String status;
  final String appliedOn;
  final String? approvedBy;
  final String? remarks;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.approvedBy,
    this.remarks,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final fromDateStr = json['from_date']?.toString() ?? '';
    final toDateStr = json['to_date']?.toString() ?? '';
    double calculatedDays = 1.0;
    try {
      if (fromDateStr.isNotEmpty && toDateStr.isNotEmpty) {
        final from = DateTime.parse(fromDateStr);
        final to = DateTime.parse(toDateStr);
        calculatedDays = to.difference(from).inDays + 1.0;
      }
    } catch (_) {}

    String resolvedStatus = json['status']?.toString().toLowerCase() ?? 'pending';
    if (resolvedStatus == 'approve') resolvedStatus = 'approved';
    if (resolvedStatus == 'reject') resolvedStatus = 'rejected';

    return LeaveRequest(
      id: json['id']?.toString() ?? '',
      employeeId: json['emp_id']?.toString() ?? json['emp_code']?.toString() ?? '',
      employeeName: json['emp_info']?['name']?.toString() ?? 'N/A',
      department: json['emp_info']?['employee']?['department']?['name']?.toString() ?? 'N/A',
      leaveType: json['leave_type']?['name']?.toString() ?? 'N/A',
      fromDate: fromDateStr,
      toDate: toDateStr,
      days: calculatedDays,
      reason: json['reason']?.toString() ?? '',
      status: resolvedStatus,
      appliedOn: json['created_at'] != null ? json['created_at'].toString().substring(0, 10) : '',
      approvedBy: json['approved_by']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}

class LeaveMockData {
  static List<LeaveRequest> get requests => [
    const LeaveRequest(
      id: 'LV001',
      employeeId: 'EMP001',
      employeeName: 'Rahul Sharma',
      department: 'Engineering',
      leaveType: 'Casual Leave',
      fromDate: '2026-07-20',
      toDate: '2026-07-22',
      days: 3.0,
      reason: 'Family function at home town',
      status: 'pending',
      appliedOn: '2026-07-15',
    ),
    const LeaveRequest(
      id: 'LV002',
      employeeId: 'EMP003',
      employeeName: 'Amit Verma',
      department: 'Finance',
      leaveType: 'Earned Leave',
      fromDate: '2026-07-10',
      toDate: '2026-07-14',
      days: 5.0,
      reason: 'Personal work and travel',
      status: 'approved',
      appliedOn: '2026-07-05',
      approvedBy: 'Priya Singh',
      remarks: 'Approved, handover details submitted',
    ),
    const LeaveRequest(
      id: 'LV003',
      employeeId: 'EMP004',
      employeeName: 'Sneha Patel',
      department: 'Design',
      leaveType: 'Casual Leave',
      fromDate: '2026-07-18',
      toDate: '2026-07-18',
      days: 1.0,
      reason: 'Doctor appointment',
      status: 'rejected',
      appliedOn: '2026-07-14',
      approvedBy: 'Priya Singh',
      remarks: 'Rejected due to urgent design delivery deadline',
    ),
    const LeaveRequest(
      id: 'LV004',
      employeeId: 'EMP006',
      employeeName: 'Ananya Roy',
      department: 'Engineering',
      leaveType: 'Maternity Leave',
      fromDate: '2026-08-01',
      toDate: '2026-11-30',
      days: 122.0,
      reason: 'Maternity leave application',
      status: 'pending',
      appliedOn: '2026-07-12',
    ),
  ];
}

class LeavePolicy {
  final String id;
  final String title;
  final String description;
  final int totalDays;
  final int usedDays;
  final String iconName;
  final int colorValue;

  const LeavePolicy({
    required this.id,
    required this.title,
    required this.description,
    required this.totalDays,
    this.usedDays = 0,
    required this.iconName,
    required this.colorValue,
  });

  LeavePolicy copyWith({int? totalDays, int? usedDays}) {
    return LeavePolicy(
      id: id,
      title: title,
      description: description,
      totalDays: totalDays ?? this.totalDays,
      usedDays: usedDays ?? this.usedDays,
      iconName: iconName,
      colorValue: colorValue,
    );
  }
}

class CompOffCredit {
  final String id;
  final String employeeId;
  final String employeeName;
  final String dutyDate;
  final String expiryDate;
  final String reason;
  final String status; // pending, approved, used, lapsed
  final String attachment;
  final String? duration;

  const CompOffCredit({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.dutyDate,
    required this.expiryDate,
    required this.reason,
    required this.status,
    required this.attachment,
    this.duration,
  });

  CompOffCredit copyWith({String? status}) {
    return CompOffCredit(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      dutyDate: dutyDate,
      expiryDate: expiryDate,
      reason: reason,
      status: status ?? this.status,
      attachment: attachment,
      duration: duration,
    );
  }
}
