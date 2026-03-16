abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  String? getCurrentUserId();
}
