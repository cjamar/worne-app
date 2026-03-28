import 'dart:io';

import 'package:prestar_ropa_app/features/item/data/datasources/item_remote_datasource.dart';
import 'package:prestar_ropa_app/features/item/data/models/item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemRemoteDatasourceImpl implements ItemRemoteDatasource {
  final SupabaseClient supabase;

  ItemRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<ItemModel>> getItems(String userId) async {
    try {
      // propios
      final ownItemsResponse = await supabase
          .from('items')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      // ids compartidos
      final accessResponse = await supabase
          .from('item_access')
          .select('item_id')
          .eq('shared_with_user_id', userId);

      final itemIds = accessResponse.map((e) => e['item_id']).toList();

      List sharedItemsResponse = [];

      if (itemIds.isNotEmpty) {
        sharedItemsResponse = await supabase
            .from('items')
            .select()
            .inFilter('id', itemIds)
            .order('created_at', ascending: false);
      }

      final allItems = [
        ...ownItemsResponse.map((e) => ItemModel.fromJson(e)),
        ...sharedItemsResponse.map((e) => ItemModel.fromJson(e)),
      ];

      return allItems;
    } catch (e) {
      throw Exception('Error al obtener items: $e');
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
