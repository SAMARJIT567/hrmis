// ============================================================
// 📁 lib/features/attendance/models/attendance_model.dart
// ─────────────────────────────────────────────────────────────
// Attendance data model.
// ============================================================

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? workHours;
  final String? remarks;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workHours,
    this.remarks,
  });
}

class AttendanceMockData {
  static List<AttendanceRecord> get todayRecords => [
    const AttendanceRecord(
      id: 'ATT001',
      employeeId: 'EMP001',
      employeeName: 'Rahul Sharma',
      department: 'Engineering',
      date: 'Today',
      checkIn: '09:02 AM',
      checkOut: '06:15 PM',
      status: 'present',
      workHours: '9h 13m',
    ),
    const AttendanceRecord(
      id: 'ATT002',
      employeeId: 'EMP002',
      employeeName: 'Priya Singh',
      department: 'HR',
      date: 'Today',
      checkIn: '09:45 AM',
      checkOut: null,
      status: 'late',
      workHours: null,
    ),
    const AttendanceRecord(
      id: 'ATT003',
      employeeId: 'EMP003',
      employeeName: 'Amit Verma',
      department: 'Finance',
      date: 'Today',
      checkIn: null,
      checkOut: null,
      status: 'absent',
      workHours: null,
    ),
    const AttendanceRecord(
      id: 'ATT004',
      employeeId: 'EMP004',
      employeeName: 'Sneha Patel',
      department: 'Design',
      date: 'Today',
      checkIn: '08:55 AM',
      checkOut: '06:00 PM',
      status: 'present',
      workHours: '9h 5m',
    ),
    const AttendanceRecord(
      id: 'ATT005',
      employeeId: 'EMP005',
      employeeName: 'Vikas Kumar',
      department: 'Marketing',
      date: 'Today',
      checkIn: null,
      checkOut: null,
      status: 'leave',
      workHours: null,
      remarks: 'Casual Leave',
    ),
    const AttendanceRecord(
      id: 'ATT006',
      employeeId: 'EMP006',
      employeeName: 'Ananya Roy',
      department: 'Engineering',
      date: 'Today',
      checkIn: '09:10 AM',
      checkOut: '01:00 PM',
      status: 'half-day',
      workHours: '3h 50m',
    ),
    const AttendanceRecord(
      id: 'ATT007',
      employeeId: 'EMP007',
      employeeName: 'Rohit Mishra',
      department: 'Sales',
      date: 'Today',
      checkIn: '09:00 AM',
      checkOut: '06:05 PM',
      status: 'present',
      workHours: '9h 5m',
    ),
    const AttendanceRecord(
      id: 'ATT008',
      employeeId: 'EMP008',
      employeeName: 'Kavya Reddy',
      department: 'Operations',
      date: 'Today',
      checkIn: '08:45 AM',
      checkOut: '05:55 PM',
      status: 'present',
      workHours: '9h 10m',
    ),
  ];
}