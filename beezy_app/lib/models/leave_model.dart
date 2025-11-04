class Leave {
  final int? id;
  final int leaveTypeId; // FK to LeaveType
  final String startDate;
  final String endDate;
  final String dayType; // full or half
  final double totalDays;
  final String reason;
  final String? status;
  final String? employeeName;
  final String? employeeCode;
  final String? leaveTypeName;
  final String? attachmentUrl;

  Leave({
    this.id,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.dayType,
    required this.totalDays,
    required this.reason,
    this.status,
    this.employeeName,
    this.employeeCode,
    this.leaveTypeName,
    this.attachmentUrl,
  });

  /// Convert JSON → Leave
  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      leaveTypeId: json['leave_type'] is Map
          ? json['leave_type']['id']
          : json['leave_type'] ?? 0,
      leaveTypeName: json['leave_type'] is Map
          ? json['leave_type']['name']
          : json['leave_type_name'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      dayType: json['day_type'] ?? 'full',
      totalDays: (json['total_days'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      employeeCode:
          json['employee_code'] ?? json['employee']?['employee_code'],
      employeeName: json['employee_name'] ??
          "${json['employee']?['first_name'] ?? ''} ${json['employee']?['last_name'] ?? ''}".trim(),
      attachmentUrl: json['attachment'] ?? '',
    );
  }

  /// ✅ Convert Leave → JSON for POST (includes employee)
  Map<String, dynamic> toJson() {
    return {
      'employee': employeeCode, // 👈 added this line
      'leave_type': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'day_type': dayType,
      'total_days': totalDays,
      'reason': reason,
    };
  }
}
