import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String status;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.status,
    required this.createdAt,
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
  ];
}
