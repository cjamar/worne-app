import 'package:flutter/material.dart';
import '../../features/item/domain/entities/item.dart';
import '../../features/item/domain/entities/item_status.dart';
import '../../features/item/domain/entities/shared_group.dart';

class ItemsHelper {
  static Map<String, List<Item>> groupSharedItemsByUser(
    List<Item> sharedItems,
    String currentUserId,
    List<SharedGroup> sharedGroups,
  ) {
    final Map<String, List<Item>> grouped = {};

    for (var item in sharedItems) {
      if (item.sharedGroupId == null) continue;

      final matches = sharedGroups.where((g) => g.id == item.sharedGroupId);

      if (matches.isEmpty) continue;

      final group = matches.first;

      final otherUserName = group.userAId == currentUserId
          ? group.nameUserB
          : group.nameUserA;

      final safeName = otherUserName ?? 'Usuario';

      grouped.putIfAbsent(safeName, () => []);
      grouped[safeName]!.add(item);
    }

    return grouped;
  }

  static ItemStatus? mapStringToStatus(String filter) {
    switch (filter) {
      case 'Disponibles':
        return ItemStatus.available;
      case 'Prestados':
        return ItemStatus.loaned;
      case 'Reservados':
        return ItemStatus.reserved;
      case 'Perdidos':
        return ItemStatus.lost;
      default:
        return null;
    }
  }

  static Color colorStatus(Item item) {
    Color color;

    switch (item.status) {
      case ItemStatus.available:
        color = Colors.green;
        break;
      case ItemStatus.loaned:
        color = Colors.blue;
        break;
      case ItemStatus.reserved:
        color = Colors.deepPurpleAccent;
        break;
      case ItemStatus.lost:
        color = Colors.grey;
        break;
    }
    return color;
  }
}
