import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.createdAt,
  });

  User copyWith({String? username, String? avatarUrl, String? email}) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, username, avatarUrl, createdAt];
}
