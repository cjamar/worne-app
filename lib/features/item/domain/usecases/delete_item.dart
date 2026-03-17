import 'package:prestar_ropa_app/features/item/domain/repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  Future<void> call(String id) async => await repository.deleteItem(id);
}
