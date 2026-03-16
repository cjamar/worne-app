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
          .insert(user.toJson())
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
}
