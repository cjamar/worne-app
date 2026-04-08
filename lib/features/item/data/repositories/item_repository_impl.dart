import 'dart:io';
import '../../domain/entities/item.dart';
import '../../domain/entities/shared_group.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_datasource_impl.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDatasourceImpl datasource;

  ItemRepositoryImpl(this.datasource);

  @override
  Future<List<Item>> getItems(String userId) async {
    return (await datasource.getItems(userId)).map((e) => e as Item).toList();
  }

  @override
  Future<Item?> getItemById(String id) async =>
      await datasource.getItemById(id);

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
        sharedGroupId: item.sharedGroupId,
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
        sharedGroupId: item.sharedGroupId,
      ),
    );
  }

  @override
  Future<void> deleteItem(String id) async => await datasource.deleteItem(id);

  @override
  Future<String?> uploadImage(File file) async =>
      await datasource.uploadImage(file);

  @override
  Future<void> shareItem(String itemId, String userId) async =>
      await datasource.shareItem(itemId, userId);

  @override
  Future<void> shareItemByEmail(String itemId, String email) async =>
      await datasource.shareItemByEmail(itemId, email);

  @override
  Future<Map<String, SharedGroup>> groupSharedItemsByUser(
    String currentUserId,
  ) async => await datasource.groupSharedItemsByUser(currentUserId);

  @override
  Future<void> removeItemFromShared(
    String itemId,
    String ownerId,
    String sharedWithUserId,
  ) async => datasource.removeItemFromShared(itemId, ownerId, sharedWithUserId);
}
