class Leave {
  final int? id;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String dayType;
  final double totalDays;
  final String reason;
  final String? status;
  final String? employeeName;
  final String? employeeCode;
  final String? leaveTypeName;
  final String? attachmentUrl;
  final List<Map<String, dynamic>> approvalRecords;

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
    this.approvalRecords = const [],
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? 0,
      leaveTypeId: json['leave_type'] ?? 0,
      leaveTypeName: json['leave_type_name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      dayType: json['day_type'] ?? 'full',
      totalDays: (json['total_days'] is num)
          ? (json['total_days'] as num).toDouble()
          : double.tryParse(json['total_days']?.toString() ?? '0') ?? 0.0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      employeeCode: json['employee_code']?.toString(),
      employeeName: json['employee_name']?.toString() ?? '',
      attachmentUrl: json['attachment_url'] ?? json['attachment'] ?? '',
      approvalRecords: (json['approval_records'] is List)
          ? List<Map<String, dynamic>>.from(json['approval_records'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'day_type': dayType,
      'total_days': totalDays,
      'reason': reason,
    };
  }
}
