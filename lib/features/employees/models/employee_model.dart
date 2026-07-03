// ============================================================
// 📁 lib/features/employees/models/employee_model.dart
// ─────────────────────────────────────────────────────────────
// Employee data model with all HR-related fields.
// ============================================================

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final String employeeType;
  final String status;
  final String joiningDate;
  final double salary;
  final String gender;
  final String address;
  final String? reportingTo;
  final int leaveBalance;
  final String? avatarUrl;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.employeeType,
    required this.status,
    required this.joiningDate,
    required this.salary,
    required this.gender,
    required this.address,
    this.reportingTo,
    this.leaveBalance = 12,
    this.avatarUrl,
  });

  bool get isActive => status == 'active';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      department: json['department'] as String,
      designation: json['designation'] as String,
      employeeType: json['employee_type'] as String? ?? 'Full-time',
      status: json['status'] as String? ?? 'active',
      joiningDate: json['joining_date'] as String,
      salary: (json['salary'] as num).toDouble(),
      gender: json['gender'] as String? ?? 'Male',
      address: json['address'] as String? ?? '',
      reportingTo: json['reporting_to'] as String?,
      leaveBalance: json['leave_balance'] as int? ?? 12,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'department': department,
    'designation': designation,
    'employee_type': employeeType,
    'status': status,
    'joining_date': joiningDate,
    'salary': salary,
    'gender': gender,
    'address': address,
    'reporting_to': reportingTo,
    'leave_balance': leaveBalance,
    'avatar_url': avatarUrl,
  };

  Employee copyWith({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? designation,
    String? status,
    double? salary,
    int? leaveBalance,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      employeeType: employeeType,
      status: status ?? this.status,
      joiningDate: joiningDate,
      salary: salary ?? this.salary,
      gender: gender,
      address: address,
      reportingTo: reportingTo,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      avatarUrl: avatarUrl,
    );
  }
}

class EmployeeMockData {
  static List<Employee> get employees => [
    const Employee(
      id: 'EMP001',
      name: 'Rahul Sharma',
      email: 'rahul@techcorp.com',
      phone: '+91 98765 43210',
      department: 'Engineering',
      designation: 'Senior Developer',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '01 Jan 2021',
      salary: 85000,
      gender: 'Male',
      address: 'Mumbai, Maharashtra',
      reportingTo: 'Priya Singh',
      leaveBalance: 8,
    ),
    const Employee(
      id: 'EMP002',
      name: 'Priya Singh',
      email: 'priya@techcorp.com',
      phone: '+91 98765 43211',
      department: 'HR',
      designation: 'HR Manager',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '15 Mar 2019',
      salary: 75000,
      gender: 'Female',
      address: 'Delhi, India',
      reportingTo: 'CEO',
      leaveBalance: 10,
    ),
    const Employee(
      id: 'EMP003',
      name: 'Amit Verma',
      email: 'amit@techcorp.com',
      phone: '+91 98765 43212',
      department: 'Finance',
      designation: 'Accounts Manager',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '10 Jun 2020',
      salary: 65000,
      gender: 'Male',
      address: 'Bangalore, Karnataka',
      reportingTo: 'CFO',
      leaveBalance: 6,
    ),
    const Employee(
      id: 'EMP004',
      name: 'Sneha Patel',
      email: 'sneha@techcorp.com',
      phone: '+91 98765 43213',
      department: 'Design',
      designation: 'UI/UX Designer',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '20 Sep 2022',
      salary: 60000,
      gender: 'Female',
      address: 'Pune, Maharashtra',
      reportingTo: 'Rahul Sharma',
      leaveBalance: 12,
    ),
    const Employee(
      id: 'EMP005',
      name: 'Vikas Kumar',
      email: 'vikas@techcorp.com',
      phone: '+91 98765 43214',
      department: 'Marketing',
      designation: 'Marketing Lead',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '05 Feb 2021',
      salary: 70000,
      gender: 'Male',
      address: 'Hyderabad, Telangana',
      reportingTo: 'CEO',
      leaveBalance: 9,
    ),
    const Employee(
      id: 'EMP006',
      name: 'Ananya Roy',
      email: 'ananya@techcorp.com',
      phone: '+91 98765 43215',
      department: 'Engineering',
      designation: 'Flutter Developer',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '12 Jul 2023',
      salary: 55000,
      gender: 'Female',
      address: 'Kolkata, West Bengal',
      reportingTo: 'Rahul Sharma',
      leaveBalance: 14,
    ),
    const Employee(
      id: 'EMP007',
      name: 'Rohit Mishra',
      email: 'rohit@techcorp.com',
      phone: '+91 98765 43216',
      department: 'Sales',
      designation: 'Sales Executive',
      employeeType: 'Part-time',
      status: 'inactive',
      joiningDate: '01 Apr 2022',
      salary: 40000,
      gender: 'Male',
      address: 'Chennai, Tamil Nadu',
      reportingTo: 'Vikas Kumar',
      leaveBalance: 4,
    ),
    const Employee(
      id: 'EMP008',
      name: 'Kavya Reddy',
      email: 'kavya@techcorp.com',
      phone: '+91 98765 43217',
      department: 'Operations',
      designation: 'Operations Manager',
      employeeType: 'Full-time',
      status: 'active',
      joiningDate: '22 Nov 2020',
      salary: 72000,
      gender: 'Female',
      address: 'Ahmedabad, Gujarat',
      reportingTo: 'CEO',
      leaveBalance: 7,
    ),
  ];
}