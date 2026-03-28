// Report model
enum ReportType {
  spam,
  inappropriate,
  harassment,
  misinformation,
  violence,
  other,
}

class Report {
  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final ReportType type;
  final String? description;
  final String? evidence;
  final ReportStatus status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.type,
    this.description,
    this.evidence,
    this.status = ReportStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      targetType: json['targetType'] ?? '',
      targetId: json['targetId'] ?? '',
      type: ReportType.values.firstWhere(
        (ReportType e) => e.name == json['type'],
        orElse: () => ReportType.other,
      ),
      description: json['description'],
      evidence: json['evidence'],
      status: ReportStatus.values.firstWhere(
        (ReportStatus e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'type': type.name,
      'description': description,
      'evidence': evidence,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum ReportStatus {
  pending,
  reviewed,
  resolved,
  rejected,
}
