import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> ensureUserExists(supabase.User user);
  Future<String> uploadUserAvatar(File file);
}
