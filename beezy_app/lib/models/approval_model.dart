class ApprovalRecord {
  final int id;
  final String approvalType;        // approval_type.name
  final String approverName;
  final String creatorName;
  final String status;
  final String? comment;
  final String? approvedAt;
  final String createdAt;
  final int? level;                 // <- add this
  final bool isProperApprover;
  final bool wasNotified;
  final String? relatedObject;
  final String? richContent;
  final String? documentUrl;

  ApprovalRecord({
    required this.id,
    required this.approvalType,
    required this.approverName,
    required this.creatorName,
    required this.status,
    this.comment,
    this.approvedAt,
    required this.createdAt,
    this.level,
    this.isProperApprover = false,
    this.wasNotified = false,
    this.relatedObject,
    this.richContent,
    this.documentUrl,
  });

  factory ApprovalRecord.fromJson(Map<String, dynamic> json) {
    return ApprovalRecord(
      id: json['id'] ?? 0,
      approvalType: json['approval_type']?['name'] ?? '',
      approverName: json['approver_name'] ?? '',
      creatorName: json['creator_name'] ?? '',
      status: json['status'] ?? '',
      comment: json['comment'],
      approvedAt: json['approved_at'],
      createdAt: json['created_at'] ?? '',
      level: json['level'] is int ? json['level'] : (json['level'] != null ? int.tryParse(json['level'].toString()) : null),
      isProperApprover: json['is_proper_approver'] ?? false,
      wasNotified: json['was_notified'] ?? false,
      relatedObject: json['related_object'],
      richContent: json['rich_content'],
      documentUrl: json['document_url'],
    );
  }
}
