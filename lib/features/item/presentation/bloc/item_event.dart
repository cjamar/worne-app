import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadItems extends ItemEvent {
  final String? userId;
  const LoadItems([this.userId]);

  @override
  List<Object?> get props => [userId];
}

class AddItem extends ItemEvent {
  final Item item;
  const AddItem(this.item);

  @override
  List<Object?> get props => [item];
}

class EditItem extends ItemEvent {
  final Item item;
  const EditItem(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteEvent extends ItemEvent {
  final Item item;
  const DeleteEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UploadItemImageEvent extends ItemEvent {
  final File imageFile;
  const UploadItemImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class FilterItems extends ItemEvent {
  final ItemStatus? status;
  const FilterItems(this.status);

  @override
  List<Object?> get props => [status];
}

class ShareItemWithUser extends ItemEvent {
  final String itemId;
  final String userId;
  const ShareItemWithUser(this.itemId, this.userId);

  @override
  List<Object?> get props => [itemId, userId];
}
