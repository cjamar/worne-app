import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';

class RemoveItemFromShared {
  final ItemRepository repository;
  RemoveItemFromShared(this.repository);

  Future<void> call(
    String itemId,
    String ownerId,
    String sharedWithUserId,
  ) async =>
      await repository.removeItemFromShared(itemId, ownerId, sharedWithUserId);
}
