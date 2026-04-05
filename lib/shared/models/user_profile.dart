class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

