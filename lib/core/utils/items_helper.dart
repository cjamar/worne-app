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
}
