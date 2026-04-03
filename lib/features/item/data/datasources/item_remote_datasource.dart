import 'dart:io';
import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';

import '../models/item_model.dart';

abstract class ItemRemoteDatasource {
  Future<List<ItemModel>> getItems(String userId);
  Future<ItemModel?> getItemById(String id);
  Future<void> insertItem(ItemModel item);
  Future<void> updateItem(ItemModel item);
  Future<void> deleteItem(String id);
  Future<String?> uploadImage(File file);
  Future<void> shareItem(String itemId, String userId);
  Future<void> shareItemByEmail(String itemId, String email);
  Future<List<SharedGroup>> getSharedGroups(String userId);
}
