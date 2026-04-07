import 'package:flutter/material.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';
import '../widgets/item_card.dart';
import 'item_form_page.dart';

class SharedItemsPage extends StatelessWidget {
  final String username;
  final List<Item> items;
  const SharedItemsPage({
    super.key,
    required this.username,
    required this.items,
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
      onLongPress: () {},
    ),
  );

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
