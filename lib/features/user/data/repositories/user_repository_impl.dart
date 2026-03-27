import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<User?> getCurrentUser() async {
    final currentUserId = ''; // Aquí vendrá el userId de Supabase Auth
    final UserModel? userModel = await remoteDataSource.getCurrentUser(
      currentUserId,
    );
    return userModel;
  }

  @override
  Future<User?> getUserById(String id) async {
    final UserModel? userModel = await remoteDataSource.getUserById(id);
    return userModel;
  }

  @override
  Future<User> createUser(User user) async {
    final UserModel userModel = UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );

    final UserModel createdUser = await remoteDataSource.createUser(userModel);
    return createdUser;
  }

  @override
  Future<User> updateUser(User user) async {
    final UserModel userModel = UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );

    final UserModel updatedUser = await remoteDataSource.updateUser(userModel);
    return updatedUser;
  }

  @override
  Future<void> ensureUserExists(supabase.User user) async {
    final userModel = UserModel.fromSupabase(user);
    await remoteDataSource.ensureUserExists(userModel);
  }

  @override
  Future<String> uploadUserAvatar(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'avatars/$fileName.jpg';
    final client = supabase.Supabase.instance.client;

    await client.storage.from('avatars').upload(path, file);
    return client.storage.from('avatars').getPublicUrl(path);
  }
}
