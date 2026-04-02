import 'package:flutter/material.dart';
import '../../features/item/domain/entities/item.dart';
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
      case 'Perdidos':
        return ItemStatus.losted;
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
      case ItemStatus.losted:
        color = Colors.grey;
        break;
    }
    return color;
  }
}
