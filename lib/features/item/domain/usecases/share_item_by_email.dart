import '../repositories/item_repository.dart';

class ShareItemByEmail {
  final ItemRepository repository;
  ShareItemByEmail(this.repository);

  Future<void> call(String itemId, String email) =>
      repository.shareItemByEmail(itemId, email);
}
