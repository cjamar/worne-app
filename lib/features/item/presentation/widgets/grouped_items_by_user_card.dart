import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/features/item/presentation/widgets/items_collage.dart';

import '../../domain/entities/item.dart';

class GroupedItemsByUserCard extends StatelessWidget {
  final Map<String, List<Item>> groupByUser;
  final int index;
  final VoidCallback? onTap;
  const GroupedItemsByUserCard({
    super.key,
    required this.groupByUser,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final entry = groupByUser.entries.elementAt(index);
    final userName = entry.key;
    final itemsList = entry.value;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: size.height * 0.15,
        margin: EdgeInsets.symmetric(
          vertical: size.height * 0.005,
          horizontal: size.height * 0.005,
        ),
        // decoration: BoxDecoration(color: Colors.amber),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ItemsCollage(items: itemsList, width: size.width * 0.3),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: size.height * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compartido con $userName',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text('${itemsList.length} items en común'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // child: ListTile(
      //   minTileHeight: size.height * 0.15,
      //   contentPadding: EdgeInsets.zero,
      //   visualDensity: VisualDensity(vertical: 4),
      //   tileColor: Colors.amber,
      //   title: Text('Compartido con $userName'),
      //   subtitle: Text('${itemsList.length} items en común'),
      //   leading: ItemsCollage(
      //     items: itemsList,
      //     width: size.width * 0.2,
      //     height: size.height,
      //   ),
      // ),
    );
  }
}
