import '../entities/user.dart';
import '../repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<User> call(User user) async => await repository.createUser(user);
}
