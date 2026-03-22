import 'dart:io';

import 'package:prestar_ropa_app/features/item/data/datasources/item_remote_datasource.dart';
import 'package:prestar_ropa_app/features/item/data/models/item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemRemoteDatasourceImpl implements ItemRemoteDatasource {
  final SupabaseClient supabase;

  ItemRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<ItemModel>> getItems() async {
    final response = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false);
    return response.map((e) => ItemModel.fromJson(e)).toList();
  }

  @override
  Future<ItemModel?> getItemById(String id) async {
    final response = await supabase
        .from('items')
        .select()
        .eq('id', id)
        .single();
    return ItemModel.fromJson(response);
  }

  @override
  Future<void> insertItem(ItemModel item) async {
    await supabase.from('items').insert(item.toJson());
  }

  @override
  Future<void> updateItem(ItemModel item) async {
    if (item.id == null) {
      throw Exception('No se puede actualizar un item sin id');
    }

    await supabase.from('items').update(item.toJson()).eq('id', item.id!);
  }

  @override
  Future<void> deleteItem(String id) async {
    await supabase.from('items').delete().eq('id', id);
  }

  @override
  Future<String?> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'items/$fileName.jpg';

    await supabase.storage.from('items-images').upload(path, file);

    final publicUrl = supabase.storage.from('items-images').getPublicUrl(path);

    return publicUrl;
  }
}
