import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      items.isEmpty ? _emptyContainer(size) : _sharedItemsList(size, context);

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
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar item'),
        content: const Text('¿Deseas eliminar este producto?'),
        actions: [
          _textButtonDialog(
            size,
            context,
            'Cancelar',
            Colors.grey.shade400,
            Colors.black,
            false,
          ),
          _textButtonDialog(
            size,
            context,
            'Eliminar',
            Colors.redAccent,
            Colors.white,
            true,
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _removeItemFromShared(item, context);
    }
  }

  _textButtonDialog(
    Size size,
    BuildContext context,
    String action,
    Color backgroundColor,
    Color foregroundColor,
    bool confirmButton,
  ) => TextButton(
    onPressed: () => Navigator.pop(context, confirmButton),
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.06),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    ),
    child: Text(action),
  );

  _removeItemFromShared(Item item, BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    if (item.ownerId != currentUserId) {
      SimpleWidgets.snackbar(
        context,
        'No puedes eliminar items que no son tuyos',
        Colors.red,
      );
      return;
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
