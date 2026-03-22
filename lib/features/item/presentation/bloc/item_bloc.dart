import 'package:flutter_bloc/flutter_bloc.dart';
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
        final items = await getItems();
        emit(ItemLoaded(items));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<AddItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await createItem(event.item);
        add(LoadItems());
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await updateItem(event.item);
        add(LoadItems());
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<DeleteEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await deleteItem(event.itemId);
        add(LoadItems());
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
  }
}
