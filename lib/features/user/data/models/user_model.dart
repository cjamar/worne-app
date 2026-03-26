import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    avatarUrl: json['avatar_url'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'avatar_url': avatarUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  factory UserModel.fromSupabase(supabase.User user) {
    final metadata = user.userMetadata;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: metadata?['name'] ?? metadata?['username'] ?? '',
      createdAt: DateTime.parse(user.createdAt),
    );
  }
}
