import 'package:equatable/equatable.dart';
import 'item_status.dart';

class Item extends Equatable {
  final String? id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final ItemStatus status;
  final DateTime? createdAt;
  final bool isShared;
  final String? sharedGroupId;

  const Item({
    this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.status,
    this.createdAt,
    this.isShared = false,
    this.sharedGroupId,
  });

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    imageUrl,
    category,
    status,
    createdAt,
    isShared,
    sharedGroupId,
  ];
}
