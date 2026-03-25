import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';

import '../entities/item.dart';

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  Future<List<Item>> call(String userId) async =>
      await repository.getItems(userId);
}
