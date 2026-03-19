import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/item_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(LoadItems());
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(body: _homeBody(size), floatingActionButton: _fab());
  }

  _fab() => FloatingActionButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemFormPage()),
    ),
    child: Icon(Icons.add),
  );

  _homeBody(Size size) => SizedBox(
    width: size.width,
    height: size.height,
    child: BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is ItemError) {
          return _errorContainer(size, state.message);
        }
        if (state is ItemLoaded) {
          if (state.items.isEmpty) {
            return _emptyContainer(size);
          }
          return _itemList(size, state.items);
        }
        return const SizedBox.shrink();
      },
    ),
  );

  _errorContainer(Size size, String message) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error),
          Text('Ha ocurrido un error, $message', textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  _emptyContainer(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox),
          Text('Aún no tienes ningún producto, ¡añádelo a la lista!'),
        ],
      ),
    ),
  );

  _itemList(Size size, List<Item> items) => Container(
    width: size.width * 0.95,
    height: size.height * 0.8,
    color: Colors.yellow,
    child: ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => _itemCard(size, items[index]),
    ),
  );

  _itemCard(Size size, Item item) => Card(
    child: ListTile(
      onTap: () => _goToDetail(item),
      onLongPress: () async =>
          await _confirmDeleteDialog(size, item.id.toString()),
      title: Text(item.name),
      subtitle: Text(item.description),
    ),
  );

  _goToDetail(Item item) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );

  Future<void> _confirmDeleteDialog(Size size, String itemId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar item'),
        content: const Text('¿Deseas eliminar este producto?'),
        actions: [
          _textButtonDialog(
            size,
            'Cancelar',
            Colors.grey.shade400,
            Colors.black,
            false,
          ),
          _textButtonDialog(
            size,
            'Eliminar',
            Colors.redAccent,
            Colors.white,
            true,
          ),
        ],
      ),
    );
    if (confirmed == true) _deleteItem(itemId);
  }

  _textButtonDialog(
    Size size,
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

  _deleteItem(String itemId) =>
      context.read<ItemBloc>().add(DeleteEvent(itemId));
}
