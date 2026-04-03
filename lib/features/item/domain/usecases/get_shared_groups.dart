import '../entities/shared_group.dart';
import '../repositories/item_repository.dart';

class GetSharedGroups {
  final ItemRepository repository;
  GetSharedGroups(this.repository);

  Future<List<SharedGroup>> call(String userId) async =>
      repository.getSharedGroups(userId);
}
