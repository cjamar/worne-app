import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetCurrentUser {
  final UserRepository repository;

  GetCurrentUser(this.repository);

  Future<User?> call() async => await repository.getCurrentUser();
}
