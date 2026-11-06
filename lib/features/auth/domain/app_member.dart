class AppMember {
  final int id;
  final String name;
  final String email;
  final String role;



  const AppMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppMember.fromJson(Map<String, dynamic> json) {
    return AppMember(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'BUYER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  bool get isBuyer => role == 'BUYER';
  bool get isSeller => role == 'SELLER';
  bool get isAdmin => role == 'ADMIN';
}
