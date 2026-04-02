import 'package:equatable/equatable.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';

import '../../domain/entities/item.dart';

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
