// ============================================================
// 📁 lib/features/payroll/models/payroll_model.dart
// ─────────────────────────────────────────────────────────────
// Payroll data model.
// ============================================================

class PayrollRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String designation;
  final String month;
  final double basicSalary;
  final double hra;
  final double travelAllowance;
  final double specialAllowance;
  final double pf;
  final double esi;
  final double tax;
  final double otherDeductions;
  final String status;
  final String processedOn;
  final String? paidOn;

  const PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.designation,
    required this.month,
    required this.basicSalary,
    required this.hra,
    required this.travelAllowance,
    required this.specialAllowance,
    required this.pf,
    required this.esi,
    required this.tax,
    required this.otherDeductions,
    required this.status,
    required this.processedOn,
    this.paidOn,
  });

  double get grossSalary => basicSalary + hra + travelAllowance + specialAllowance;
  double get totalDeductions => pf + esi + tax + otherDeductions;
  double get netSalary => grossSalary - totalDeductions;
}

class PayrollMockData {
  static List<PayrollRecord> get records => [
    const PayrollRecord(
      id: 'PAY001', employeeId: 'EMP001', employeeName: 'Rahul Sharma',
      department: 'Engineering', designation: 'Senior Developer',
      month: 'May 2025', basicSalary: 55000, hra: 22000,
      travelAllowance: 5000, specialAllowance: 3000,
      pf: 6600, esi: 962, tax: 4500, otherDeductions: 0,
      status: 'paid', processedOn: '01 May 2025', paidOn: '01 May 2025',
    ),
    const PayrollRecord(
      id: 'PAY002', employeeId: 'EMP002', employeeName: 'Priya Singh',
      department: 'HR', designation: 'HR Manager',
      month: 'May 2025', basicSalary: 48000, hra: 19200,
      travelAllowance: 4500, specialAllowance: 3300,
      pf: 5760, esi: 840, tax: 3500, otherDeductions: 0,
      status: 'paid', processedOn: '01 May 2025', paidOn: '01 May 2025',
    ),
    const PayrollRecord(
      id: 'PAY003', employeeId: 'EMP003', employeeName: 'Amit Verma',
      department: 'Finance', designation: 'Accounts Manager',
      month: 'May 2025', basicSalary: 42000, hra: 16800,
      travelAllowance: 3500, specialAllowance: 2700,
      pf: 5040, esi: 735, tax: 2800, otherDeductions: 0,
      status: 'pending', processedOn: '01 May 2025',
    ),
    const PayrollRecord(
      id: 'PAY004', employeeId: 'EMP004', employeeName: 'Sneha Patel',
      department: 'Design', designation: 'UI/UX Designer',
      month: 'May 2025', basicSalary: 38000, hra: 15200,
      travelAllowance: 3000, specialAllowance: 3800,
      pf: 4560, esi: 665, tax: 2200, otherDeductions: 0,
      status: 'processing', processedOn: '01 May 2025',
    ),
    const PayrollRecord(
      id: 'PAY005', employeeId: 'EMP005', employeeName: 'Vikas Kumar',
      department: 'Marketing', designation: 'Marketing Lead',
      month: 'May 2025', basicSalary: 45000, hra: 18000,
      travelAllowance: 4000, specialAllowance: 3000,
      pf: 5400, esi: 788, tax: 3200, otherDeductions: 0,
      status: 'paid', processedOn: '01 May 2025', paidOn: '02 May 2025',
    ),
  ];
}