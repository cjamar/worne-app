import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../repositories/user_repository.dart';

class EnsureUserExists {
  final UserRepository repository;
  EnsureUserExists(this.repository);

  Future<void> call(supabase.User user) => repository.ensureUserExists(user);
}
