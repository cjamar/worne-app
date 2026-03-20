import '../../domain/entities/item.dart';

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
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'],
    ownerId: json['owner_id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
    category: json['category'],
    status: json['status'],
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
    'status': status,
  };
}
