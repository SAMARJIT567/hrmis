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
  static List<LeaveRequest> get requests => [
    const LeaveRequest(
      id: 'LVE001', employeeId: 'EMP003', employeeName: 'Amit Verma',
      department: 'Finance', leaveType: 'Sick Leave',
      fromDate: '25 May 2025', toDate: '26 May 2025', days: 2,
      reason: 'Fever and cold, doctor advised rest.',
      status: 'pending', appliedOn: '24 May 2025',
    ),
    const LeaveRequest(
      id: 'LVE002', employeeId: 'EMP005', employeeName: 'Vikas Kumar',
      department: 'Marketing', leaveType: 'Casual Leave',
      fromDate: '22 May 2025', toDate: '22 May 2025', days: 1,
      reason: 'Family function.',
      status: 'approved', appliedOn: '20 May 2025',
      approvedBy: 'Priya Singh',
    ),
    const LeaveRequest(
      id: 'LVE003', employeeId: 'EMP004', employeeName: 'Sneha Patel',
      department: 'Design', leaveType: 'Earned Leave',
      fromDate: '01 Jun 2025', toDate: '05 Jun 2025', days: 5,
      reason: 'Vacation trip.',
      status: 'pending', appliedOn: '23 May 2025',
    ),
    const LeaveRequest(
      id: 'LVE004', employeeId: 'EMP006', employeeName: 'Ananya Roy',
      department: 'Engineering', leaveType: 'Sick Leave',
      fromDate: '18 May 2025', toDate: '19 May 2025', days: 2,
      reason: 'Migraine.',
      status: 'approved', appliedOn: '17 May 2025',
      approvedBy: 'Rahul Sharma',
    ),
    const LeaveRequest(
      id: 'LVE005', employeeId: 'EMP008', employeeName: 'Kavya Reddy',
      department: 'Operations', leaveType: 'Casual Leave',
      fromDate: '10 May 2025', toDate: '10 May 2025', days: 1,
      reason: 'Personal work.',
      status: 'rejected', appliedOn: '09 May 2025',
      approvedBy: 'CEO', remarks: 'Critical project deadline.',
    ),
    const LeaveRequest(
      id: 'LVE006', employeeId: 'EMP001', employeeName: 'Rahul Sharma',
      department: 'Engineering', leaveType: 'Earned Leave',
      fromDate: '28 May 2025', toDate: '30 May 2025', days: 3,
      reason: 'Annual family trip.',
      status: 'pending', appliedOn: '25 May 2025',
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
