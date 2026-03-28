// User model
class User {
  final String id;
  final String username;
  final String? avatar;
  final String? bio;
  final int followers;
  final int following;
  final bool isBlocked;
  final bool isBlacklisted;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.avatar,
    this.bio,
    this.followers = 0,
    this.following = 0,
    this.isBlocked = false,
    this.isBlacklisted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      isBlocked: json['isBlocked'] ?? false,
      isBlacklisted: json['isBlacklisted'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'followers': followers,
      'following': following,
      'isBlocked': isBlocked,
      'isBlacklisted': isBlacklisted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}