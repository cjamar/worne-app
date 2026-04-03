import 'dart:io';
import 'package:prestar_ropa_app/core/utils/items_helper.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';
import 'item_remote_datasource.dart';

class ItemRemoteDatasourceImpl implements ItemRemoteDatasource {
  final SupabaseClient supabase;

  ItemRemoteDatasourceImpl(this.supabase);

  // GET
  @override
  Future<List<ItemModel>> getItems(String userId) async {
    try {
      final ownItems = await supabase
          .from('items')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final sharedGroupIds = (await getSharedGroups(
        userId,
      )).map((g) => g.id).toList();

      List sharedItems = [];
      if (sharedGroupIds.isNotEmpty) {
        sharedItems = await supabase
            .from('items')
            .select()
            .inFilter('shared_group_id', sharedGroupIds)
            .order('created_at', ascending: false);
      }

      return [
        ...ownItems.map((e) => ItemModel.fromJson(e).copyWith(isShared: false)),
        ...sharedItems.map(
          (e) => ItemModel.fromJson(e).copyWith(isShared: true),
        ),
      ];
    } catch (e) {
      throw Exception('Error al obtener items: $e');
    }
  }

  @override
  Future<List<SharedGroup>> getSharedGroups(String userId) async {
    // Traemos los shared_groups donde participa el usuario
    final response = await supabase
        .from('shared_group')
        .select('id, user_a_id, user_b_id')
        .or('user_a_id.eq.$userId,user_b_id.eq.$userId');

    // Mapeamos a SharedGroup y traemos el nombre de cada usuario
    final List<SharedGroup> groups = [];
    for (final g in response) {
      final userAId = g['user_a_id'];
      final userBId = g['user_b_id'];

      // Traemos nombre de usuario de la tabla users
      final nameUserA = await supabase
          .from('users')
          .select('username')
          .eq('id', userAId)
          .maybeSingle();
      final nameUserB = await supabase
          .from('users')
          .select('username')
          .eq('id', userBId)
          .maybeSingle();

      groups.add(
        SharedGroup(
          id: g['id'],
          userAId: userAId,
          userBId: userBId,
          nameUserA: nameUserA?['username'] ?? 'Usuario sin identificar',
          nameUserB: nameUserB?['username'] ?? 'Usuario sin identificar',
        ),
      );
    }
    return groups;
  }

  // TODO: Método pendiente de uso (sustituirá a getItems)
  @override
  Future<Map<String, dynamic>> getItemsGrouped(String userId) async {
    try {
      // 1️⃣ Items propios
      final ownItemsResponse = await supabase
          .from('items')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final ownItems = ownItemsResponse
          .map((e) => ItemModel.fromJson(e).copyWith(isShared: false))
          .toList();

      // 2️⃣ Items compartidos por shared_group
      final sharedGroups = await getSharedGroups(userId);
      final sharedGroupIds = sharedGroups.map((g) => g.id).toList();

      List<ItemModel> sharedItems = [];
      if (sharedGroupIds.isNotEmpty) {
        final sharedItemsResponse = await supabase
            .from('items')
            .select()
            .inFilter('shared_group_id', sharedGroupIds)
            .order('created_at', ascending: false);

        sharedItems = sharedItemsResponse
            .map((e) => ItemModel.fromJson(e).copyWith(isShared: true))
            .toList();
      }

      // 3️⃣ Agrupar los items compartidos por el otro usuario
      final groupedSharedItems = ItemsHelper.groupSharedItemsByUser(
        sharedItems,
        userId,
        sharedGroups,
      );

      // 🔹 Retornamos todo en un Map con ambas vistas
      return {'ownItems': ownItems, 'sharedItems': groupedSharedItems};
    } catch (e) {
      throw Exception('Error al obtener items agrupados: $e');
    }
  }

  // @override
  // Future<List<ItemModel>> getItems(String userId) async {
  //   try {
  //     final response = await supabase
  //         .from('items')
  //         .select()
  //         .order('created_at', ascending: false);

  //     return response.map((e) {
  //       final item = ItemModel.fromJson(e);

  //       return item.copyWith(isShared: item.ownerId != userId);
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Error al obtener items: $e');
  //   }
  // }

  @override
  Future<ItemModel?> getItemById(String id) async {
    try {
      final response = await supabase
          .from('items')
          .select()
          .eq('id', id)
          .single();
      return ItemModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener item por id: $e');
    }
  }

  // INSERT
  @override
  Future<void> insertItem(ItemModel item) async {
    try {
      await supabase.from('items').insert(item.toJson());
    } catch (e) {
      throw Exception('Error al insertar item: $e');
    }
  }

  // UPDATE
  @override
  Future<void> updateItem(ItemModel item) async {
    if (item.id == null) {
      throw Exception('No se puede actualizar un item sin id');
    }
    try {
      await supabase.from('items').update(item.toJson()).eq('id', item.id!);
    } catch (e) {
      throw Exception('Error al actualizar el item: $e');
    }
  }

  // DELETE
  @override
  Future<void> deleteItem(String id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar item: $e');
    }
  }

  // SHARE
  @override
  Future<void> shareItem(String itemId, String userId) async {
    final existing = await supabase
        .from('item_access')
        .select('id')
        .eq('item_id', itemId)
        .eq('shared_with_user_id', userId)
        .maybeSingle();

    if (existing != null) return;

    await supabase.from('item_access').insert({
      'item_id': itemId,
      'shared_with_user_id': userId,
    });
  }

  @override
  Future<void> shareItemByEmail(String itemId, String email) async {
    final response = await supabase
        .from('users')
        .select('id')
        .eq('email', email.toLowerCase())
        .maybeSingle();

    if (response == null) throw Exception('Usuario no encontrado');

    final userId = response['id'];
    await shareItem(itemId, userId);
  }

  // IMAGE
  @override
  Future<String?> uploadImage(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'items/$fileName.jpg';

      await supabase.storage.from('items-images').upload(path, file);

      final publicUrl = supabase.storage
          .from('items-images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
