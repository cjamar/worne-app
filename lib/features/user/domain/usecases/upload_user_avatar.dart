import 'dart:io';
import '../repositories/user_repository.dart';

class UploadUserAvatar {
  final UserRepository repository;
  UploadUserAvatar(this.repository);

  Future<String> call(File file) => repository.uploadUserAvatar(file);
}
