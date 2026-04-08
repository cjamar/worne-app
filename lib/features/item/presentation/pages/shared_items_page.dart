import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/shared/widgets/remove_item_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';
import '../bloc/item_bloc.dart';
import '../widgets/item_card.dart';
import 'item_form_page.dart';

class SharedItemsPage extends StatelessWidget {
  final String username;
  final List<Item> items;
  final String otherUserId;
  const SharedItemsPage({
    super.key,
    required this.username,
    required this.items,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text('Compartido con $username'),
      ),
      backgroundColor: Colors.white,
      body: _sharedItemsBody(size, context),
    );
  }

  _sharedItemsBody(Size size, BuildContext context) =>
      BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemLoadedGrouped) {
            Navigator.pop(context);
          }
          if (state is ItemError) {
            SimpleWidgets.snackbar(context, state.message, Colors.red);
          }
        },
        child: items.isEmpty
            ? _emptyContainer(size)
            : _sharedItemsList(size, context),
      );

  _sharedItemsList(Size size, BuildContext context) => GridView.builder(
    shrinkWrap: true,
    itemCount: items.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
    ),
    itemBuilder: (context, index) => ItemCard(
      key: ValueKey(items[index].id),
      item: items[index],
      onTap: () => _goToDetail(items[index], context),
      onLongPress: () => _confirmDeleteDialog(size, items[index], context),
    ),
  );

  Future<void> _confirmDeleteDialog(
    Size size,
    Item item,
    BuildContext context,
  ) async {
    final confirmed = await RemoveItemModal.showConfirmDialog(
      context: context,
      title: 'Sacar del grupo',
      content: '¿Quieres eliminar "${item.name}" del grupo de $username?',
      confirmText: 'Sacar del grupo',
    );
    if (confirmed == true && context.mounted) {
      _removeItemFromShared(item, context);
    }
  }

  _removeItemFromShared(Item item, BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    if (item.ownerId != currentUserId) {
      SimpleWidgets.snackbar(
        context,
        'No puedes eliminar items que no son tuyos',
        Colors.red,
      );
      return;
    } else {
      context.read<ItemBloc>().add(
        RemoveSharedItemEvent(item.id!, currentUserId, otherUserId),
      );
      SimpleWidgets.snackbar(
        context,
        'Has eliminado del grupo compartido el item ${item.name}',
        Colors.blue,
      );
    }
  }

  _emptyContainer(Size size) => SimpleWidgets.containerWithIcon(
    size,
    Icons.error,
    'Ha ocurrido un error, no hay items',
  );

  _goToDetail(Item item, BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );
}
