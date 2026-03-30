import '../repositories/item_repository.dart';

class ShareItem {
  final ItemRepository repository;
  ShareItem(this.repository);

  Future<void> call(String itemId, String userId) =>
      repository.shareItem(itemId, userId);
}
