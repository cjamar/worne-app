import '../repositories/auth_repository.dart';

class GetCurrentUserId {
  final AuthRepository repository;

  GetCurrentUserId(this.repository);

  String? call() => repository.getCurrentUserId();
}
