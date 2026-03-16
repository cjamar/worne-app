import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
}
