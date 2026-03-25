import 'dart:io';

import 'package:prestar_ropa_app/features/item/data/datasources/item_remote_datasource_impl.dart';
import 'package:prestar_ropa_app/features/item/data/models/item_model.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDatasourceImpl datasource;

  ItemRepositoryImpl(this.datasource);

  @override
  Future<List<Item>> getItems(String userId) async {
    return (await datasource.getItems(userId)).map((e) => e as Item).toList();
  }

  @override
  Future<Item?> getItemById(String id) async {
    return await datasource.getItemById(id);
  }

  @override
  Future<void> createItem(Item item) async {
    await datasource.insertItem(
      ItemModel(
        id: item.id,
        ownerId: item.ownerId,
        name: item.name,
        description: item.description,
        imageUrl: item.imageUrl,
        category: item.category,
        status: item.status,
        createdAt: item.createdAt,
      ),
    );
  }

  @override
  Future<void> updateItem(Item item) async {
    await datasource.updateItem(
      ItemModel(
        id: item.id,
        ownerId: item.ownerId,
        name: item.name,
        description: item.description,
        imageUrl: item.imageUrl,
        category: item.category,
        status: item.status,
        createdAt: item.createdAt,
      ),
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await datasource.deleteItem(id);
  }

  @override
  Future<String?> uploadImage(File file) async {
    return await datasource.uploadImage(file);
  }
}
