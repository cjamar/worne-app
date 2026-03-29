import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.status,
    required super.createdAt,
    super.isShared,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'],
    ownerId: json['owner_id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
    category: json['category'],
    status: ItemStatus.values.firstWhere((e) => e.name == json['status']),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'category': category,
    'status': status.name,
  };

  ItemModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    ItemStatus? status,
    DateTime? createdAt,
    bool? isShared,
  }) {
    return ItemModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
    );
  }
}
