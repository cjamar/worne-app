import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';
import '../entities/item.dart';

class GetItemById {
  final ItemRepository repository;

  GetItemById(this.repository);

  Future<Item?> call(String id) async => await repository.getItemById(id);
}
