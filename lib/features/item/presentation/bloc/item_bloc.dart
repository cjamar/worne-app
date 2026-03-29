import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
import '../../domain/usecases/create_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
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
  List<Item> _allItems = [];
  ItemStatus? _activeFilter;

  ItemBloc({
    required this.getItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
    required this.uploadItemImage,
  }) : super(ItemInitial()) {
    on<LoadItems>((event, emit) async {
      emit(ItemLoading());
      try {
        final uId =
            event.userId ?? Supabase.instance.client.auth.currentUser!.id;
        final items = await getItems(uId);
        _allItems = items;
        emit(ItemLoaded(_applyFilter(), activeFilter: _activeFilter));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<AddItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await createItem(event.item);
        _allItems = [event.item, ..._allItems];
        emit(ItemLoaded(_applyFilter(), activeFilter: _activeFilter));
        //  add(LoadItems(event.item.ownerId));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await updateItem(event.item);
        add(LoadItems(event.item.ownerId));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await deleteItem(event.item.id!);
        add(LoadItems(event.item.ownerId));
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

      emit(ItemLoaded(_applyFilter(), activeFilter: _activeFilter));
    });
  }

  List<Item> _applyFilter() {
    if (_activeFilter == null) return _allItems;

    return _allItems.where((item) => item.status == _activeFilter).toList();
  }
}
