import 'dart:io';
import '../repositories/item_repository.dart';

class UploadItemImage {
  final ItemRepository repository;

  UploadItemImage(this.repository);

  Future<String?> call(File file) async => await repository.uploadImage(file);
}
