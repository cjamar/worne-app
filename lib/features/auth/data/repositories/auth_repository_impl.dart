import 'package:prestar_ropa_app/features/user/domain/entities/user.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> signIn({required String email, required String password}) =>
      remoteDatasource.signIn(email: email, password: password);

  @override
  Future<void> signUp({required String email, required String password}) =>
      remoteDatasource.signUp(email: email, password: password);

  @override
  Future<void> signInWithGoogle() => remoteDatasource.signInWithGoogle();

  @override
  Future<void> signOut() => remoteDatasource.signOut();

  @override
  String? getCurrentUserId() => remoteDatasource.getCurrentUserId();
}
