import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient supabase;

  AuthRemoteDatasourceImpl(this.supabase);

  @override
  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  String? getCurrentUserId() {
    final user = supabase.auth.currentUser;
    return user?.id;
  }
}
