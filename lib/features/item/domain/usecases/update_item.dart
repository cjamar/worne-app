import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';
import '../entities/item.dart';

class UpdateItem {
  final ItemRepository repository;

  UpdateItem(this.repository);

  Future<void> call(Item item) async => await repository.updateItem(item);
}
