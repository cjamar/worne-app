import 'package:equatable/equatable.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<Item> items;
  final ItemStatus? activeFilter;
  const ItemLoaded(this.items, {this.activeFilter});

  @override
  List<Object?> get props => [items, activeFilter];
}

class ItemLoadedGrouped extends ItemState {
  final Map<String, SharedGroup> groupedSharedItems;
  final ItemStatus? activeFilter;
  final List<Item> allItems;

  const ItemLoadedGrouped(
    this.groupedSharedItems,
    this.activeFilter,
    this.allItems,
  );

  @override
  List<Object?> get props => [groupedSharedItems, activeFilter, allItems];
}

class ItemError extends ItemState {
  final String message;
  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImageUploading extends ItemState {}

class ImageUploaded extends ItemState {
  final String imageUrl;
  const ImageUploaded(this.imageUrl);
}

class ImageUploadError extends ItemState {
  final String message;
  const ImageUploadError(this.message);
}

class ItemSharedSuccess extends ItemState {
  final String message;
  const ItemSharedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ItemSharedError extends ItemState {
  final String message;
  const ItemSharedError(this.message);

  @override
  List<Object?> get props => [message];
}
