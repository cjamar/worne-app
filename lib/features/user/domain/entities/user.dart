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

  @override
  List<Object?> get props => [id, email, username, avatarUrl, createdAt];
}
