import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/domain/usecases/remove_item_from_shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
import '../../domain/entities/shared_group.dart';
import '../../domain/usecases/create_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/get_shared_groups.dart';
import '../../domain/usecases/group_shared_items_by_user.dart';
import '../../domain/usecases/share_item.dart';
import '../../domain/usecases/share_item_by_email.dart';
import '../../domain/usecases/update_item.dart';
import '../../domain/usecases/upload_item_image.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItems getItems;
  final CreateItem createItem;
  final UpdateItem updateItem;
  final DeleteItem deleteItem;
  final UploadItemImage uploadItemImage;
  final ShareItem shareItem;
  final ShareItemByEmail shareItemByEmail;
  final GetSharedGroups getSharedGroups;
  final GroupSharedItemsByUser groupSharedItemsByUser;
  final RemoveItemFromShared removeItemFromShared;
  List<Item> _allItems = [];
  ItemStatus? _activeFilter;

  ItemBloc({
    required this.getItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
    required this.uploadItemImage,
    required this.shareItem,
    required this.shareItemByEmail,
    required this.getSharedGroups,
    required this.groupSharedItemsByUser,
    required this.removeItemFromShared,
  }) : super(ItemInitial()) {
    on<LoadItems>((event, emit) async {
      emit(ItemLoading());

      try {
        // 🔹 Obtenemos el ID del usuario actual
        final uId =
            event.userId ?? Supabase.instance.client.auth.currentUser!.id;

        // 🔹 1️⃣ Traemos todos los items del usuario (propios + shared flag)
        _allItems = await getItems(uId); // 🔹 actualizamos _allItems

        // 🔹 2️⃣ Obtenemos solo los items propios
        final ownItems = _allItems.where((i) => !i.isShared).toList();

        // 🔹 3️⃣ Llamamos a groupSharedItemsByUser para agrupar items compartidos
        final groupedSharedItems = await groupSharedItemsByUser(uId);

        // 🔹 4️⃣ Emitimos estado con items propios y agrupados por "otro usuario"
        emit(ItemLoadedGrouped(ownItems, groupedSharedItems, _activeFilter));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    // Refactor de AddItem
    on<AddItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await createItem(event.item);
        _allItems = [event.item, ..._allItems];

        // Emitimos el estado correcto agrupado
        await _emitGroupedState(emit, _allItems, event.item.ownerId);
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await updateItem(event.item);
        // Reemplazar item en _allItems
        final index = _allItems.indexWhere((i) => i.id == event.item.id);
        if (index != -1) _allItems[index] = event.item;
        // Emitir estado agrupado
        await _emitGroupedState(emit, _allItems, event.item.ownerId);
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await deleteItem(event.item.id!);
        // Eliminar item de _allItems
        _allItems.removeWhere((i) => i.id == event.item.id);
        // Emitir estado agrupado
        await _emitGroupedState(emit, _allItems, event.item.ownerId);
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<UploadItemImageEvent>((event, emit) async {
      emit(ImageUploading());

      try {
        final url = await uploadItemImage(event.imageFile);
        if (url != null) {
          emit(ImageUploaded(url));
        } else {
          emit(ImageUploadError('No se pudo subir la imagen'));
        }
      } catch (e) {
        emit(ImageUploadError(e.toString()));
      }
    });

    on<FilterItems>((event, emit) async {
      _activeFilter = event.status;
      final filteredItems = _allItems
          .where(
            (item) => _activeFilter == null || item.status == _activeFilter,
          )
          .toList();
      // Emitimos estado agrupado con los items filtrados
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _emitGroupedState(emit, filteredItems, userId);
    });

    // EN DESHUSO DE MOMENTO
    // on<ShareItemWithUser>((event, emit) async {
    //   emit(ItemLoading());
    //   try {
    //     // 1️⃣ Compartir el item
    //     await shareItem(event.itemId, event.userId);

    //     // 2️⃣ Refrescar todos los items del usuario actual
    //     final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    //     _allItems = await getItems(currentUserId);

    //     // 3️⃣ Emitir estado actualizado con items propios y compartidos
    //     await _emitGroupedState(emit, _allItems, currentUserId);
    //   } catch (e) {
    //     emit(ItemError(e.toString()));
    //   }
    // });

    on<ShareItemByEmailEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await shareItemByEmail(event.itemId, event.email);

        emit(ItemSharedSuccess('Item compartido con ${event.email}'));

        // 🔹 Refrescar _allItems desde Supabase
        final uId = Supabase.instance.client.auth.currentUser!.id;
        _allItems = await getItems(uId);

        // 🔹 Emitir el estado actualizado con items propios y compartidos
        // await _emitGroupedState(emit, _allItems, uId);
        add(LoadItems());
      } catch (e) {
        emit(ItemSharedError('Error al compartir, ${e.toString()}'));
      }
    });

    // item_bloc.dart
    on<RemoveSharedItemEvent>((event, emit) async {
      if (state is ItemLoadedGrouped) {
        emit(ItemLoading());
        try {
          await removeItemFromShared(
            event.itemId,
            event.ownerId,
            event.otherUserId,
          );
          // 2️⃣ Volvemos a cargar los items del usuario (refresh)
          final ownItems = await getItems(event.ownerId);
          final groupedSharedItems = await groupSharedItemsByUser(
            event.ownerId,
          );
          emit(ItemLoadedGrouped(ownItems, groupedSharedItems, _activeFilter));
        } catch (e) {
          emit(ItemError('No se pudo eliminar el item: $e'));
        }
      }
    });
  }

  List<Item> _applyFilter() {
    if (_activeFilter == null) return _allItems;

    return _allItems.where((item) => item.status == _activeFilter).toList();
  }

  // Método privado para emitir el estado agrupado
  Future<void> _emitGroupedState(
    Emitter<ItemState> emit,
    List<Item> allItems,
    String userId,
  ) async {
    try {
      final ownItems = allItems.where((i) => !i.isShared).toList();

      // Llamamos a groupSharedItemsByUser para agrupar items compartidos
      final groupedSharedItems = await groupSharedItemsByUser(userId);

      emit(ItemLoadedGrouped(ownItems, groupedSharedItems, _activeFilter));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  Future<void> shareItemToUserByEmail(String itemId, String email) async {
    try {
      await shareItemByEmail(itemId, email);
    } catch (e) {
      rethrow;
    }
  }
}
