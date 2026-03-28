// Topic / hashtag model
class Topic {
  final String id;
  final String name;
  final String? description;
  final int postsCount;
  final int discussionsCount;
  final bool isFollowing;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.name,
    this.description,
    this.postsCount = 0,
    this.discussionsCount = 0,
    this.isFollowing = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      postsCount: json['postsCount'] ?? 0,
      discussionsCount: json['discussionsCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'postsCount': postsCount,
      'discussionsCount': discussionsCount,
      'isFollowing': isFollowing,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Topic copyWith({
    String? id,
    String? name,
    String? description,
    int? postsCount,
    int? discussionsCount,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      postsCount: postsCount ?? this.postsCount,
      discussionsCount: discussionsCount ?? this.discussionsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}