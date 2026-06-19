class CoupleInfo {
  final String? partnerId;
  final String? partnerUsername;
  final String? partnerAvatarUrl;
  final DateTime? relationshipDate;

  CoupleInfo({
    this.partnerId,
    this.partnerUsername,
    this.partnerAvatarUrl,
    this.relationshipDate,
  });

  factory CoupleInfo.fromJson(Map<String, dynamic> json) {
    return CoupleInfo(
      partnerId: json['partner_id'] as String?,
      partnerUsername: json['partner_username'] as String?,
      partnerAvatarUrl: json['partner_avatar_url'] as String?,
      relationshipDate: json['relationship_date'] != null
          ? DateTime.parse(json['relationship_date'] as String)
          : null,
    );
  }
}

class CoupleRequest {
  final String id;
  final String fromUsername;
  final String? fromAvatarUrl;
  final DateTime createdAt;

  CoupleRequest({
    required this.id,
    required this.fromUsername,
    this.fromAvatarUrl,
    required this.createdAt,
  });

  factory CoupleRequest.fromJson(Map<String, dynamic> json) {
    return CoupleRequest(
      id: json['id'] as String,
      fromUsername: json['from_user']['username'] as String,
      fromAvatarUrl: json['from_user']['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
