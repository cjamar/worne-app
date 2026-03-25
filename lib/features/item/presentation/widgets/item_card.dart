import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ItemCard({super.key, required this.item, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.symmetric(
          vertical: size.height * 0.005,
          horizontal: size.height * 0.005,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(size.width * 0.05),
        ),
        child: Column(children: [_imageCard(size), _contentCard(size)]),
      ),
    );
  }

  _imageCard(Size size) => ClipRRect(
    // borderRadius: BorderRadius.circular(size.width * 0.025),
    child: Container(
      width: size.width,
      height: size.height * 0.2,
      color: Colors.grey.shade200,
      child: item.imageUrl.trim().isNotEmpty
          ? Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: _iconBrokenImage(size)),
            )
          : _iconImage(size),
    ),
  );

  _iconBrokenImage(Size size) => Icon(
    Icons.broken_image,
    size: size.width * 0.15,
    color: Colors.grey.shade300,
  );

  _iconImage(Size size) => Center(
    child: Icon(
      Icons.image,
      size: size.width * 0.15,
      color: Colors.grey.shade300,
    ),
  );

  _contentCard(Size size) => Container(
    width: size.width,
    padding: EdgeInsetsGeometry.all(size.width * 0.02),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [_nameCard(size), _statusBadgeCard(size)],
    ),
  );

  _nameCard(Size size) => Container(
    width: size.width,
    padding: EdgeInsets.only(bottom: size.height * 0.01),
    child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 1),
  );

  _statusBadgeCard(Size size) {
    Color color;

    switch (item.status) {
      case ItemStatus.available:
        color = Colors.green;
        break;
      case ItemStatus.loaned:
        color = Colors.blue;
        break;
      case ItemStatus.reserved:
        color = Colors.deepPurpleAccent;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.width * 0.005,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Text(item.status.name, style: TextStyle(color: color)),
    );
  }
}
