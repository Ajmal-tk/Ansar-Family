class PostModel {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final String? authorRole;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.authorRole,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    String? authorName;
    String? authorRole;
    if (json['profiles'] != null && json['profiles'] is Map) {
      authorName = json['profiles']['full_name'] as String?;
      authorRole = json['profiles']['role'] as String?;
    }

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      authorName: authorName,
      authorRole: authorRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
