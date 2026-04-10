import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
import '../../domain/usecases/create_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/group_shared_items_by_user.dart';
import '../../domain/usecases/remove_item_from_shared.dart';
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
    required this.groupSharedItemsByUser,
    required this.removeItemFromShared,
  }) : super(ItemInitial()) {
    on<LoadItems>((event, emit) async {
      emit(ItemLoading());

      try {
        final uId =
            event.userId ?? Supabase.instance.client.auth.currentUser!.id;
        _allItems = await getItems(uId);
        await _emitGroupedState(emit, _allItems, uId);

        // final filteredItems = _applyFilter();
        // final ownItems = filteredItems.where((i) => !i.isShared).toList();
        // final groupedSharedItems = await groupSharedItemsByUser(uId);

        // emit(
        //   ItemLoadedGrouped(
        //     ownItems,
        //     groupedSharedItems,
        //     _activeFilter,
        //     _allItems,
        //   ),
        // );
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<AddItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await createItem(event.item);
        _allItems = [event.item, ..._allItems];

        await _emitGroupedState(emit, _allItems, event.item.ownerId);
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await updateItem(event.item);

        final index = _allItems.indexWhere((i) => i.id == event.item.id);
        if (index != -1) _allItems[index] = event.item;

        await _emitGroupedState(emit, _allItems, event.item.ownerId);
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await deleteItem(event.item.id!);

        _allItems.removeWhere((i) => i.id == event.item.id);

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

    on<FilterItems>((event, emit) {
      if (state is ItemLoadedGrouped) {
        final currentState = state as ItemLoadedGrouped;
        _activeFilter = event.status;
        final filteredItems = _applyFilter(currentState.allItems);
        final ownItems = filteredItems.where((i) => !i.isShared).toList();
        // 👇 reutilizamos los grupos actuales SIN volver a calcular
        final groupedSharedItems = currentState.groupedSharedItems;

        emit(
          ItemLoadedGrouped(
            ownItems,
            groupedSharedItems,
            _activeFilter,
            currentState.allItems, // 🔥 fuente de verdad intacta
          ),
        );
      }
    });

    on<ShareItemByEmailEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await shareItemByEmail(event.itemId, event.email);

        emit(ItemSharedSuccess('Item compartido con ${event.email}'));

        final uId = Supabase.instance.client.auth.currentUser!.id;
        _allItems = await getItems(uId);

        add(LoadItems());
      } catch (e) {
        emit(ItemSharedError('Error al compartir, ${e.toString()}'));
      }
    });

    on<RemoveSharedItemEvent>((event, emit) async {
      if (state is ItemLoadedGrouped) {
        emit(ItemLoading());
        try {
          await removeItemFromShared(
            event.itemId,
            event.ownerId,
            event.otherUserId,
          );

          // final ownItems = await getItems(event.ownerId);
          // final groupedSharedItems = await groupSharedItemsByUser(
          //   event.ownerId,
          // );
          final items = await getItems(event.ownerId);
          await _emitGroupedState(emit, items, event.ownerId);
        } catch (e) {
          emit(ItemError('No se pudo eliminar el item: $e'));
        }
      }
    });
  }

  List<Item> _applyFilter(List<Item> items) {
    if (_activeFilter == null) return items;

    return items.where((item) => item.status == _activeFilter).toList();
  }

  Future<void> _emitGroupedState(
    Emitter<ItemState> emit,
    List<Item> baseItems,
    String userId,
  ) async {
    try {
      final filteredItems = _applyFilter(baseItems);

      final ownItems = filteredItems.where((i) => !i.isShared).toList();

      final groupedSharedItems = await groupSharedItemsByUser(userId);

      final allItems = {
        for (var item in [
          ...baseItems,
          ...groupedSharedItems.values.expand((g) => g.items),
        ])
          item.id: item,
      }.values.toList();

      emit(
        ItemLoadedGrouped(
          ownItems,
          groupedSharedItems,
          _activeFilter,
          allItems,
        ),
      );
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
