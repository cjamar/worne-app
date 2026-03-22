import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';

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
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(size.width * 0.05),
      topRight: Radius.circular(size.width * 0.05),
    ),
    child: Container(
      width: size.width,
      height: size.height * 0.17,
      color: Colors.orange,
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
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.broken_image,
                  size: size.width * 0.1,
                  color: Colors.grey,
                ),
              ),
            )
          : _iconImage(size),
    ),
  );

  _iconImage(Size size) => Center(
    child: Icon(Icons.image, size: size.width * 0.1, color: Colors.grey),
  );

  _contentCard(Size size) => Padding(
    padding: EdgeInsetsGeometry.all(size.width * 0.02),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: size.height * 0.06,
          child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 2),
        ),
        _statusBadgeCard(size),
      ],
    ),
  );

  _statusBadgeCard(Size size) {
    Color color;

    switch (item.status) {
      case 'available':
        color = Colors.green;
        break;
      case 'borrowed':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Text(item.status, style: TextStyle(color: color)),
    );
  }
}
