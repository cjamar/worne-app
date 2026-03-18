import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/domain/usecases/create_item.dart';
import 'package:prestar_ropa_app/features/item/domain/usecases/get_items.dart';
import 'package:prestar_ropa_app/features/item/domain/usecases/update_item.dart';
import '../../domain/usecases/delete_item.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItems getItems;
  final CreateItem createItem;
  final UpdateItem updateItem;
  final DeleteItem deleteItem;

  ItemBloc({
    required this.getItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
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
  }
}
