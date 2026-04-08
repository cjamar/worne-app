import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';
import 'package:prestar_ropa_app/features/item/presentation/widgets/items_collage.dart';

class GroupedItemsByUserCard extends StatelessWidget {
  final Map<String, SharedGroup> groupByUser;
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
    final sharedGroup = entry.value;
    final itemsList = sharedGroup.items;
    final userName = sharedGroup.nameUserB ?? 'Usuario';

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        height: size.height * 0.15,
        margin: EdgeInsets.symmetric(
          vertical: size.height * 0.005,
          horizontal: size.height * 0.005,
        ),
        padding: EdgeInsets.only(bottom: size.height * 0.01),
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
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: size.height * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compartido con'),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _itemsLenghtContainer(size, itemsList.length),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _itemsLenghtContainer(Size size, int itemsLength) => Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(size.width * 0.04),
    ),
    padding: EdgeInsets.symmetric(
      vertical: size.width * 0.01,
      horizontal: size.width * 0.03,
    ),
    child: Text('$itemsLength items en común', style: TextStyle(fontSize: 13)),
  );
}
