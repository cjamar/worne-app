import 'package:prestar_ropa_app/features/item/data/models/item_model.dart';

abstract class ItemRemoteDatasource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel?> getItemById(String id);
  Future<void> insertItem(ItemModel item);
  Future<void> updateItem(ItemModel item);
  Future<void> deleteItem(String id);
}
