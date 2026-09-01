class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final String role; // 'admin', 'management', 'member'
  final String status; // 'pending', 'approved', 'rejected'
  final String? phone;
  final String? address;

  ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.updatedAt,
    this.role = 'member',
    this.status = 'pending',
    this.phone,
    this.address,
  });

  bool get isAdmin => role == 'admin';
  bool get isManagement => role == 'management' || role == 'admin';
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
      role: json['role'] as String? ?? 'member',
      status: json['status'] as String? ?? 'pending',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
      'status': status,
      'phone': phone,
      'address': address,
    };
  }

  ProfileModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    DateTime? updatedAt,
    String? role,
    String? status,
    String? phone,
    String? address,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
