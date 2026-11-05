class FamilyMemberModel {
  final String id;
  final String userId;
  final String name;
  final String? relation;
  final int? age;
  final String? gender;
  final String? education;
  final String? workStatus;
  final String? maritalStatus;
  final DateTime createdAt;

  FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    this.relation,
    this.age,
    this.gender,
    this.education,
    this.workStatus,
    this.maritalStatus,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      education: json['education'] as String?,
      workStatus: json['work_status'] as String?,
      maritalStatus: json['marital_status'] as String?,
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
      'gender': gender,
      'education': education,
      'work_status': workStatus,
      'marital_status': maritalStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
