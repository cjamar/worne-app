import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';

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
      appBar: AppBar(title: Text('Compartido con $username')),
      body: _sharedItemsBody(size),
    );
  }

  _sharedItemsBody(Size size) => items.isEmpty
      ? _emptyContainer(size)
      : ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _sharedItemCard(size, items[index]),
        );

  _sharedItemCard(Size size, Item item) => Container(
    margin: EdgeInsets.symmetric(vertical: size.width * 0.01),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.02),
        child: Image.network(item.imageUrl),
      ),
      title: Text(item.name),
      subtitle: Text(item.description),
      trailing: item.isShared
          ? Icon(Icons.handshake, color: Colors.deepPurpleAccent)
          : null,
    ),
  );

  _emptyContainer(Size size) => SimpleWidgets.containerWithIcon(
    size,
    Icons.error,
    'Ha ocurrido un error, no hay items',
  );
}
