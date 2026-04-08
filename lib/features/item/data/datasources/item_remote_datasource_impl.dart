import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/shared_group.dart';
import '../models/item_model.dart';
import 'item_remote_datasource.dart';

class ItemRemoteDatasourceImpl implements ItemRemoteDatasource {
  final SupabaseClient supabase;

  ItemRemoteDatasourceImpl(this.supabase);

  // GET
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

      print('ACCESS RAW: $access');

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

      // 1️⃣ Traemos todos los accesos donde el usuario está involucrado
      final allAccess = await supabase
          .from('item_access')
          .select('item_id, shared_with_user_id, owner_id')
          .or(
            'shared_with_user_id.eq.$currentUserId,owner_id.eq.$currentUserId',
          );

      if (allAccess.isEmpty) return {};

      // 2️⃣ Detectamos todos los usuarios con los que tenemos relación
      final relations = <String>{};
      for (var access in allAccess) {
        final ownerId = access['owner_id'] as String;
        final sharedWithId = access['shared_with_user_id'] as String;

        final otherUserId = (ownerId == currentUserId) ? sharedWithId : ownerId;
        if (otherUserId != currentUserId) relations.add(otherUserId);
      }

      // 3️⃣ Construimos los espacios compartidos por usuario
      final Map<String, SharedGroup> grouped = {};
      for (var otherUserId in relations) {
        // 🔹 Traemos todos los items compartidos entre currentUserId y otherUserId
        final sharedAccess = await supabase
            .from('item_access')
            .select('item_id, owner_id, shared_with_user_id')
            .or(
              'and(owner_id.eq.$currentUserId,shared_with_user_id.eq.$otherUserId),'
              'and(owner_id.eq.$otherUserId,shared_with_user_id.eq.$currentUserId)',
            );

        if (sharedAccess.isEmpty) continue;

        // 🔹 Sacamos los itemIds únicos
        final itemIds = sharedAccess.map((e) => e['item_id'] as String).toSet();

        // 🔹 Traemos los items
        final itemsRaw = <Map<String, dynamic>>[];
        for (var itemId in itemIds) {
          final res = await supabase.from('items').select().eq('id', itemId);
          itemsRaw.addAll(res);
        }

        final items = itemsRaw
            .map((e) => ItemModel.fromJson(e).copyWith(isShared: true))
            .toList();

        // 🔹 Obtenemos usernames de ambos usuarios
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
          id: otherUserId, // puedes cambiar a un id de grupo si lo defines en Supabase
          userAId: currentUserId,
          userBId: otherUserId,
          nameUserA: userARes?['username'] ?? currentUserId,
          nameUserB: userBRes?['username'] ?? otherUserId,
          items: items, // añadimos los items para la UI y acciones
        );
      }

      print('GROUPED SHARED ITEMS: $grouped');
      return grouped;
    } catch (e) {
      throw Exception('Error agrupando items compartidos: $e');
    }
  }

  // Función auxiliar para obtener los IDs de los items que el usuario posee
  Future<List<String>> _getOwnedItemIds(String userId) async {
    final response = await supabase
        .from('items')
        .select('id')
        .eq('owner_id', userId);
    return response.map<String>((e) => e['id'] as String).toList();
  }

  //TODO: DE MOMENTO ESTA EN DESHUSO
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

  // @override
  // Future<Map<String, dynamic>> getItemsGrouped(String userId) async {
  //   try {
  //     // 1️⃣ Items propios
  //     final ownItemsResponse = await supabase
  //         .from('items')
  //         .select()
  //         .eq('owner_id', userId)
  //         .order('created_at', ascending: false);

  //     final ownItems = ownItemsResponse
  //         .map((e) => ItemModel.fromJson(e).copyWith(isShared: false))
  //         .toList();

  //     // 2️⃣ Items compartidos por shared_group
  //     final sharedGroups = await getSharedGroups(userId);
  //     final sharedGroupIds = sharedGroups.map((g) => g.id).toList();

  //     List<ItemModel> sharedItems = [];
  //     if (sharedGroupIds.isNotEmpty) {
  //       final sharedItemsResponse = await supabase
  //           .from('items')
  //           .select()
  //           .inFilter('shared_group_id', sharedGroupIds)
  //           .order('created_at', ascending: false);

  //       sharedItems = sharedItemsResponse
  //           .map((e) => ItemModel.fromJson(e).copyWith(isShared: true))
  //           .toList();
  //     }

  //     // 3️⃣ Agrupar los items compartidos por el otro usuario
  //     final groupedSharedItems = groupSharedItemsByUser(sharedItems, userId);

  //     // 🔹 Retornamos todo en un Map con ambas vistas
  //     return {'ownItems': ownItems, 'sharedItems': groupedSharedItems};
  //   } catch (e) {
  //     throw Exception('Error al obtener items agrupados: $e');
  //   }
  // }

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
    final ownerId = Supabase.instance.client.auth.currentUser!.id;

    // 🔹 Evitar compartir contigo mismo
    if (ownerId == userId) {
      throw Exception('No puedes compartir un item contigo mismo');
    }

    // 🔹 Evitar duplicados
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
}
