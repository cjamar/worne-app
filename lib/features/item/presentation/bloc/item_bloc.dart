import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/core/utils/items_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
import '../../domain/usecases/create_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/get_shared_groups.dart';
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
  }) : super(ItemInitial()) {
    on<LoadItems>((event, emit) async {
      emit(ItemLoading());
      try {
        final uId =
            event.userId ?? Supabase.instance.client.auth.currentUser!.id;

        // ANTES
        // final items = await getItems(uId);
        // _allItems = items;
        // emit(ItemLoaded(_applyFilter(), activeFilter: _activeFilter));

        // AHORA
        final items = await getItems(uId);
        final sharedGroups = await getSharedGroups(uId);
        _allItems = items;
        // separar
        final ownItems = items.where((i) => !i.isShared).toList();
        final sharedItems = items.where((i) => i.isShared).toList();
        // agrupar
        final groupedSharedItems = ItemsHelper.groupSharedItemsByUser(
          sharedItems,
          uId,
          sharedGroups,
        );
        // emitir nuevo estado
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
    //   try {
    //     await shareItem(event.itemId, event.userId);
    //     add(LoadItems());
    //   } catch (e) {
    //     emit(ItemError(e.toString()));
    //   }
    // });

    // ACTUALMENTE NO SE LE LLAMA DIRECTAMENTE, LA IDEA ES REACTIVARLO
    // on<ShareItemByEmailEvent>((event, emit) async {
    //   try {
    //     await shareItemByEmail(event.itemId, event.email);
    //     //  emit(ItemSharedSuccess('Se ha compartido con éxito a ${event.email}'));
    //   } catch (e) {
    //     emit(ItemError(e.toString()));
    //   }
    // });
  }

  List<Item> _applyFilter() {
    if (_activeFilter == null) return _allItems;

    return _allItems.where((item) => item.status == _activeFilter).toList();
  }

  // Método privado para emitir el estado agrupado
  Future<void> _emitGroupedState(
    Emitter<ItemState> emit,
    List<Item> items,
    String userId,
  ) async {
    final sharedGroups = await getSharedGroups(userId);
    final ownItems = items.where((i) => !i.isShared).toList();
    final sharedItems = items.where((i) => i.isShared).toList();
    final groupedSharedItems = ItemsHelper.groupSharedItemsByUser(
      sharedItems,
      userId,
      sharedGroups,
    );
    emit(ItemLoadedGrouped(ownItems, groupedSharedItems, _activeFilter));
  }

  Future<void> shareItemToUserByEmail(String itemId, String email) async {
    try {
      await shareItemByEmail(itemId, email);
    } catch (e) {
      rethrow;
    }
  }
}
