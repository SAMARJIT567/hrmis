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
}

class LeaveMockData {
  static List<LeaveRequest> get requests => [];
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
