import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItems();
  Future<Item?> getItemById(String id);
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
}
