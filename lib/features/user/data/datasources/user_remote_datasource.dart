import '../models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<UserModel?> getCurrentUser(String userId);
  Future<UserModel?> getUserById(String id);
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
}
