import 'item.dart';

class SharedGroup {
  final String id;
  final String userAId;
  final String userBId;
  final String? nameUserA;
  final String? nameUserB;
  final List<Item> items;

  SharedGroup({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.nameUserA,
    this.nameUserB,
    this.items = const [],
  });
}
