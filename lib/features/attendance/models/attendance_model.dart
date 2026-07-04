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
  final String? checkInSelfie;
  final String? checkOutSelfie;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? employeeImage;
  final double? latitude;
  final double? longitude;

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
    this.checkInSelfie,
    this.checkOutSelfie,
    this.checkInLocation,
    this.checkOutLocation,
    this.employeeImage,
    this.latitude,
    this.longitude,
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
      checkInSelfie: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60',
      checkInLocation: 'Sector 62, Noida, UP',
      employeeImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=60',
      latitude: 28.6273,
      longitude: 77.3725,
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
      checkInSelfie: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60',
      checkInLocation: 'Cyber City, Gurugram',
      employeeImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=60',
      latitude: 28.4950,
      longitude: 77.0878,
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
      checkInSelfie: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop&q=60',
      checkInLocation: 'Hitech City, Hyderabad',
      employeeImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&auto=format&fit=crop&q=60',
      latitude: 17.4435,
      longitude: 78.3772,
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
      checkInSelfie: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&auto=format&fit=crop&q=60',
      checkInLocation: 'Whitefield, Bengaluru',
      employeeImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&auto=format&fit=crop&q=60',
      latitude: 12.9698,
      longitude: 77.7499,
    ),
  ];
}
