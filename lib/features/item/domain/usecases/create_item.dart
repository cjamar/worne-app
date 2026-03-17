import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';
import '../entities/item.dart';

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  Future<void> call(Item item) async => await repository.createItem(item);
}
