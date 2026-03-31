import 'dart:io';
import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItems(String userId);
  Future<Item?> getItemById(String id);
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<String?> uploadImage(File file);
  Future<void> shareItem(String itemId, String userId);
  Future<void> shareItemByEmail(String itemId, String email);
}
