import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'user_remote_datasource.dart';

class UserRemoteDataSourceImpl implements UserRemoteDatasource {
  final SupabaseClient supabase;

  UserRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await supabase
          .from('users')
          .upsert(user.toJson())
          .select()
          .single();
      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel?> getCurrentUser(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', id)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> ensureUserExists(UserModel user) async {
    final existing = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'username': '',
        'avatar_url': null,
      });
    }
  }
}
