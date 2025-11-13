class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final Map<String, dynamic>? extra;

  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.extra,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    Map<String, dynamic>? extra,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      extra: extra ?? this.extra,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      extra: json['extra'] is Map
          ? (json['extra'] as Map).cast<String, dynamic>()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'extra': extra,
  };
}
