/// User roles in the application
enum UserRole { student, teacher, admin, guest }

/// User model
class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? 'Naməlum',
      email: json['email'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'student': return UserRole.student;
      case 'teacher': return UserRole.teacher;
      case 'admin': return UserRole.admin;
      default: return UserRole.student;
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Demo users for mock data
  static final List<UserModel> demoUsers = [
    UserModel(
      id: '1',
      name: 'Alex Student',
      email: 'student@edu.com',
      role: UserRole.student,
      createdAt: DateTime(2024, 1, 15),
    ),
    UserModel(
      id: '2',
      name: 'Sarah Teacher',
      email: 'teacher@edu.com',
      role: UserRole.teacher,
      createdAt: DateTime(2023, 9, 1),
    ),
    UserModel(
      id: '3',
      name: 'Admin User',
      email: 'admin@edu.com',
      role: UserRole.admin,
      createdAt: DateTime(2023, 1, 1),
    ),
  ];
}
