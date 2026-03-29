import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/core/utils/items_helper.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';
import 'package:prestar_ropa_app/features/shared/widgets/simple_widgets.dart';

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
    child: Container(
      width: size.width,
      height: size.height * 0.2,
      color: Colors.grey.shade200,
      child: item.imageUrl.trim().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 300,
              memCacheHeight: 300,
              placeholder: (context, url) => SimpleWidgets.loader(),
              errorWidget: (context, url, error) =>
                  SimpleWidgets.placeholderImage(size, Icons.broken_image),
            )
          : SimpleWidgets.placeholderImage(size, Icons.image),
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
    Color color = ItemsHelper.colorStatus(item);

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
