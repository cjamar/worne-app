import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/shared_group.dart';
import '../models/item_model.dart';
import 'item_remote_datasource.dart';

class ItemRemoteDatasourceImpl implements ItemRemoteDatasource {
  final SupabaseClient supabase;

  ItemRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<ItemModel>> getItems(String userId) async {
    try {
      print('CURRENT USER ID: $userId');

      final ownItems = await supabase
          .from('items')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      final access = await supabase
          .from('item_access')
          .select('item_id')
          .eq('shared_with_user_id', userId);

      final sharedItemIds = access.map((e) => e['item_id'] as String).toList();

      List sharedItems = [];

      if (sharedItemIds.isNotEmpty) {
        sharedItems = await supabase
            .from('items')
            .select()
            .inFilter('id', sharedItemIds)
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
  Future<Map<String, SharedGroup>> groupSharedItemsByUser(
    String currentUserId,
  ) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;

      final allAccess = await supabase
          .from('item_access')
          .select('item_id, shared_with_user_id, owner_id')
          .or(
            'shared_with_user_id.eq.$currentUserId,owner_id.eq.$currentUserId',
          );

      if (allAccess.isEmpty) return {};

      final relations = <String>{};
      for (var access in allAccess) {
        final ownerId = access['owner_id'] as String;
        final sharedWithId = access['shared_with_user_id'] as String;

        final otherUserId = (ownerId == currentUserId) ? sharedWithId : ownerId;
        if (otherUserId != currentUserId) relations.add(otherUserId);
      }

      final Map<String, SharedGroup> grouped = {};
      for (var otherUserId in relations) {
        final sharedAccess = await supabase
            .from('item_access')
            .select('item_id, owner_id, shared_with_user_id')
            .or(
              'and(owner_id.eq.$currentUserId,shared_with_user_id.eq.$otherUserId),'
              'and(owner_id.eq.$otherUserId,shared_with_user_id.eq.$currentUserId)',
            );

        if (sharedAccess.isEmpty) continue;

        final itemIds = sharedAccess.map((e) => e['item_id'] as String).toSet();

        final itemsRaw = <Map<String, dynamic>>[];
        for (var itemId in itemIds) {
          final res = await supabase.from('items').select().eq('id', itemId);
          itemsRaw.addAll(res);
        }

        final items = itemsRaw
            .map((e) => ItemModel.fromJson(e).copyWith(isShared: true))
            .toList();

        final userARes = await supabase
            .from('users')
            .select('username')
            .eq('id', currentUserId)
            .maybeSingle();
        final userBRes = await supabase
            .from('users')
            .select('username')
            .eq('id', otherUserId)
            .maybeSingle();

        grouped[otherUserId] = SharedGroup(
          id: otherUserId,
          userAId: currentUserId,
          userBId: otherUserId,
          nameUserA: userARes?['username'] ?? currentUserId,
          nameUserB: userBRes?['username'] ?? otherUserId,
          items: items,
        );
      }

      print('GROUPED SHARED ITEMS: $grouped');
      return grouped;
    } catch (e) {
      throw Exception('Error agrupando items compartidos: $e');
    }
  }

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

  @override
  Future<void> insertItem(ItemModel item) async {
    try {
      await supabase.from('items').insert(item.toJson());
    } catch (e) {
      throw Exception('Error al insertar item: $e');
    }
  }

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

  @override
  Future<void> deleteItem(String id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar item: $e');
    }
  }

  @override
  Future<void> shareItem(String itemId, String userId) async {
    final ownerId = Supabase.instance.client.auth.currentUser!.id;

    if (ownerId == userId) {
      throw Exception('No puedes compartir un item contigo mismo');
    }

    final existing = await supabase
        .from('item_access')
        .select('id')
        .eq('item_id', itemId)
        .eq('shared_with_user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('item_access').insert({
        'item_id': itemId,
        'owner_id': ownerId,
        'shared_with_user_id': userId,
      });
    }
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

  @override
  Future<void> removeItemFromShared(
    String itemId,
    String ownerId,
    String sharedWithUserId,
  ) async {
    try {
      await Supabase.instance.client.from('item_access').delete().match({
        'item_id': itemId,
        'owner_id': ownerId,
        'shared_with_user_id': sharedWithUserId,
      });
    } catch (e) {
      throw Exception('Error al eliminar item de compartidos: $e');
    }
  }
}
