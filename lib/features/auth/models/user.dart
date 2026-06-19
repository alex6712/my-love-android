class User {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
