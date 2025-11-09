// =====================================================
// MODELS FOR APPROVALS AND NOTIFICATIONS
// =====================================================

class ApprovalRecord {
  final int id;
  final String approvalType;
  final int level;
  final String status;
  final String? comment;
  final String? approvedAt;
  final bool isProperApprover;
  final bool wasNotified;
  final String? richContent;
  final String? documentUrl;
  final String? relatedObject;
  final String approverName;
  final String creatorName;

  ApprovalRecord({
    required this.id,
    required this.approvalType,
    required this.level,
    required this.status,
    this.comment,
    this.approvedAt,
    required this.isProperApprover,
    required this.wasNotified,
    this.richContent,
    this.documentUrl,
    this.relatedObject,
    required this.approverName,
    required this.creatorName,
  });

  factory ApprovalRecord.fromJson(Map<String, dynamic> json) {
    return ApprovalRecord(
      id: json['id'],
      approvalType: json['approval_type']['name'],
      level: json['level'],
      status: json['status'],
      comment: json['comment'],
      approvedAt: json['approved_at'],
      isProperApprover: json['is_proper_approver'] ?? true,
      wasNotified: json['was_notified'] ?? false,
      richContent: json['rich_content'],
      documentUrl: json['document_url'],
      relatedObject: json['related_object'],
      approverName: json['approver'] != null ? json['approver']['full_name'] : '',
      creatorName: json['creator'] != null ? json['creator']['full_name'] : '',
    );
  }
}

// =====================================================
// NOTIFICATIONS
// =====================================================

class RelatedRecordInfo {
  final int id;
  final String approvalType;
  final String status;
  final String creator;
  final String approver;

  RelatedRecordInfo({
    required this.id,
    required this.approvalType,
    required this.status,
    required this.creator,
    required this.approver,
  });

  factory RelatedRecordInfo.fromJson(Map<String, dynamic> json) {
    return RelatedRecordInfo(
      id: json['id'],
      approvalType: json['approval_type'],
      status: json['status'],
      creator: json['creator'],
      approver: json['approver'],
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final String? approvalType;
  final String? status;
  final RelatedRecordInfo? relatedRecordInfo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.approvalType,
    this.status,
    this.relatedRecordInfo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
      approvalType: json['approval_type'],
      status: json['status'],
      relatedRecordInfo: json['related_record_info'] != null
          ? RelatedRecordInfo.fromJson(json['related_record_info'])
          : null,
    );
  }
}
