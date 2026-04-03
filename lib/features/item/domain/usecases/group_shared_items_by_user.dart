import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GroupSharedItemsByUser {
  final ItemRepository repository;
  GroupSharedItemsByUser(this.repository);

  Future<Map<String, List<Item>>> call(String currentUserId) async =>
      await repository.groupSharedItemsByUser(currentUserId);
}
