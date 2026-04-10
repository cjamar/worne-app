import '../../features/item/domain/entities/item.dart';
import 'package:flutter/material.dart';
import '../../features/item/domain/entities/item_status.dart';

class ItemsHelper {
  static ItemStatus? mapStringToStatus(String filter) {
    switch (filter) {
      case 'Disponibles':
        return ItemStatus.available;
      case 'Prestados':
        return ItemStatus.loaned;
      case 'Reservados':
        return ItemStatus.reserved;
      default:
        return null;
    }
  }

  static Color colorStatus(Item item) {
    Color color;
    switch (item.status) {
      case ItemStatus.available:
        color = const Color.fromARGB(255, 48, 135, 51);
        break;
      case ItemStatus.loaned:
        color = const Color.fromARGB(255, 26, 121, 199);
        break;
      case ItemStatus.reserved:
        color = const Color.fromARGB(255, 103, 64, 211);
        break;
    }
    return color;
  }
}
