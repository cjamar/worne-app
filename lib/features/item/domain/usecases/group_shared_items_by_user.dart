import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';
import '../repositories/item_repository.dart';

class GroupSharedItemsByUser {
  final ItemRepository repository;
  GroupSharedItemsByUser(this.repository);

  Future<Map<String, SharedGroup>> call(String currentUserId) async =>
      await repository.groupSharedItemsByUser(currentUserId);
}
