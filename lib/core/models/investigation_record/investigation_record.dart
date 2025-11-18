enum ReviewStatus { WRITING, PENDING, APPROVED, REJECTED }

class InvestigationRecord {
  final String recordId;
  final String caseId;
  final String? recordName;
  final String? content;
  final int securityLevel;
  final int number;
  final String? progressStatus;
  final ReviewStatus? reviewStatus;
  final String? rejectionReason;
  final Map<String, dynamic>? creator;
  final Map<String, dynamic>? reviewer;
  final String? reviewedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? requestedAt;
  final dynamic attachedFiles;

  InvestigationRecord({
    required this.recordId,
    required this.caseId,
    this.recordName,
    this.content,
    this.securityLevel = 0,
    this.number = 0,
    this.progressStatus,
    dynamic reviewStatus,
    this.rejectionReason,
    this.creator,
    this.reviewer,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
    this.requestedAt,
    this.attachedFiles,
  }) : reviewStatus = _parseReviewStatus(reviewStatus);

  factory InvestigationRecord.fromJson(Map<String, dynamic> json) {
    return InvestigationRecord(
      recordId: json['recordId']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? '',
      recordName: json['recordName']?.toString(),
      content: json['content']?.toString(),
      securityLevel: (json['securityLevel'] is int)
          ? json['securityLevel'] as int
          : (int.tryParse(json['securityLevel']?.toString() ?? '') ?? 0),
      number: (json['number'] is int)
          ? json['number'] as int
          : (int.tryParse(json['number']?.toString() ?? '') ?? 0),
      progressStatus: json['progressStatus']?.toString(),
      reviewStatus: json['reviewStatus'],
      rejectionReason: json['rejectionReason']?.toString(),
      creator: json['creator'] is Map ? Map<String, dynamic>.from(json['creator']) : null,
      reviewer: json['reviewer'] is Map ? Map<String, dynamic>.from(json['reviewer']) : null,
      reviewedAt: json['reviewedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      requestedAt: json['requestedAt']?.toString(),
      attachedFiles: json['attachedFiles'],
    );
  }

  static ReviewStatus? _parseReviewStatus(dynamic value) {
    if (value == null) return null;
    final s = value is String ? value : value.toString();
    switch (s.toUpperCase()) {
      case 'WRITING':
        return ReviewStatus.WRITING;
      case 'PENDING':
        return ReviewStatus.PENDING;
      case 'APPROVED':
        return ReviewStatus.APPROVED;
      case 'REJECTED':
        return ReviewStatus.REJECTED;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'recordId': recordId,
        'caseId': caseId,
        'recordName': recordName,
        'content': content,
        'securityLevel': securityLevel,
        'number': number,
        'progressStatus': progressStatus,
        'reviewStatus': reviewStatus == null ? null : reviewStatus.toString().split('.').last,
        'rejectionReason': rejectionReason,
        'creator': creator,
        'reviewer': reviewer,
        'reviewedAt': reviewedAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'requestedAt': requestedAt,
        'attachedFiles': attachedFiles,
      };
}
