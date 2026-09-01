class FamilyMemberModel {
  final String id;
  final String userId;
  final String name;
  final String? relation;
  final int? age;
  final DateTime createdAt;

  FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    this.relation,
    this.age,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String?,
      age: json['age'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'relation': relation,
      'age': age,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
