// ============================================================
// 📁 lib/features/attendance/models/office_settings_model.dart
// ============================================================
// Office settings model for attendance configuration
// ============================================================

class OfficeSettings {
  final String id;
  final String officeName;
  final String officeAddress;
  final double latitude;
  final double longitude;
  final String checkInTime;
  final String checkOutTime;
  final int workingHoursPerDay;
  final int breakDurationMinutes;
  final bool isCheckInRequired;
  final bool isCheckOutRequired;
  final bool isLocationTrackingEnabled;
  final bool isBiometricEnabled;
  final bool allowRemoteCheckIn;
  final bool autoApproveLeave;
  final bool sendEmailNotifications;
  final String timeZone;
  final String workingDays;
  final double allowedRadiusMeters;

  const OfficeSettings({
    required this.id,
    required this.officeName,
    required this.officeAddress,
    required this.latitude,
    required this.longitude,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingHoursPerDay,
    required this.breakDurationMinutes,
    required this.isCheckInRequired,
    required this.isCheckOutRequired,
    required this.isLocationTrackingEnabled,
    required this.isBiometricEnabled,
    required this.allowRemoteCheckIn,
    required this.autoApproveLeave,
    required this.sendEmailNotifications,
    required this.timeZone,
    required this.workingDays,
    this.allowedRadiusMeters = 100.0,
  });

  // ─── Factory from JSON ───────────────────────────────────────
  factory OfficeSettings.fromJson(Map<String, dynamic> json) {
    return OfficeSettings(
      id: json['id'] as String,
      officeName: json['office_name'] as String,
      officeAddress: json['office_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      checkInTime: json['check_in_time'] as String,
      checkOutTime: json['check_out_time'] as String,
      workingHoursPerDay: json['working_hours_per_day'] as int,
      breakDurationMinutes: json['break_duration_minutes'] as int,
      isCheckInRequired: json['is_check_in_required'] as bool,
      isCheckOutRequired: json['is_check_out_required'] as bool,
      isLocationTrackingEnabled: json['is_location_tracking_enabled'] as bool,
      isBiometricEnabled: json['is_biometric_enabled'] as bool,
      allowRemoteCheckIn: json['allow_remote_check_in'] as bool,
      autoApproveLeave: json['auto_approve_leave'] as bool,
      sendEmailNotifications: json['send_email_notifications'] as bool,
      timeZone: json['time_zone'] as String,
      workingDays: json['working_days'] as String,
      allowedRadiusMeters: (json['allowed_radius_meters'] as num?)?.toDouble() ?? 100.0,
    );
  }

  // ─── To JSON ──────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id': id,
    'office_name': officeName,
    'office_address': officeAddress,
    'latitude': latitude,
    'longitude': longitude,
    'check_in_time': checkInTime,
    'check_out_time': checkOutTime,
    'working_hours_per_day': workingHoursPerDay,
    'break_duration_minutes': breakDurationMinutes,
    'is_check_in_required': isCheckInRequired,
    'is_check_out_required': isCheckOutRequired,
    'is_location_tracking_enabled': isLocationTrackingEnabled,
    'is_biometric_enabled': isBiometricEnabled,
    'allow_remote_check_in': allowRemoteCheckIn,
    'auto_approve_leave': autoApproveLeave,
    'send_email_notifications': sendEmailNotifications,
    'time_zone': timeZone,
    'working_days': workingDays,
    'allowed_radius_meters': allowedRadiusMeters,
  };

  // ─── Default Settings ────────────────────────────────────────
  static OfficeSettings get defaultSettings {
    return OfficeSettings(
      id: 'default',
      officeName: 'TechCorp Pvt. Ltd.',
      officeAddress: 'New Delhi, India',
      latitude: 28.6139,
      longitude: 77.2090,
      checkInTime: '09:00 AM',
      checkOutTime: '06:00 PM',
      workingHoursPerDay: 8,
      breakDurationMinutes: 30,
      isCheckInRequired: true,
      isCheckOutRequired: true,
      isLocationTrackingEnabled: true,
      isBiometricEnabled: false,
      allowRemoteCheckIn: false,
      autoApproveLeave: false,
      sendEmailNotifications: true,
      timeZone: 'Asia/Kolkata',
      workingDays: 'Mon-Sat',
      allowedRadiusMeters: 100.0,
    );
  }

  // ─── Copy With ────────────────────────────────────────────────
  OfficeSettings copyWith({
    String? id,
    String? officeName,
    String? officeAddress,
    double? latitude,
    double? longitude,
    String? checkInTime,
    String? checkOutTime,
    int? workingHoursPerDay,
    int? breakDurationMinutes,
    bool? isCheckInRequired,
    bool? isCheckOutRequired,
    bool? isLocationTrackingEnabled,
    bool? isBiometricEnabled,
    bool? allowRemoteCheckIn,
    bool? autoApproveLeave,
    bool? sendEmailNotifications,
    String? timeZone,
    String? workingDays,
    double? allowedRadiusMeters,
  }) {
    return OfficeSettings(
      id: id ?? this.id,
      officeName: officeName ?? this.officeName,
      officeAddress: officeAddress ?? this.officeAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workingHoursPerDay: workingHoursPerDay ?? this.workingHoursPerDay,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      isCheckInRequired: isCheckInRequired ?? this.isCheckInRequired,
      isCheckOutRequired: isCheckOutRequired ?? this.isCheckOutRequired,
      isLocationTrackingEnabled: isLocationTrackingEnabled ?? this.isLocationTrackingEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      allowRemoteCheckIn: allowRemoteCheckIn ?? this.allowRemoteCheckIn,
      autoApproveLeave: autoApproveLeave ?? this.autoApproveLeave,
      sendEmailNotifications: sendEmailNotifications ?? this.sendEmailNotifications,
      timeZone: timeZone ?? this.timeZone,
      workingDays: workingDays ?? this.workingDays,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
    );
  }
}