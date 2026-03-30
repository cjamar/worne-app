import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/items_helper.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';

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
      onDoubleTap: () => _testShareItem(context),
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

  // TODO: esto se irá a la homePage o a la detailPage
  _testShareItem(BuildContext context) => context.read<ItemBloc>().add(
    ShareItemWithUser(item.id!, 'ce5c7733-f186-4a7a-b6da-1098b03c68c3'),
  );

  _imageCard(Size size) => Stack(
    children: [
      ClipRRect(
        child: Container(
          width: size.width,
          height: size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(size.width * 0.1),
          ),
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
      ),
      item.isShared ? _isSharedBadge(size) : SizedBox.shrink(),
    ],
  );

  _isSharedBadge(Size size) => Positioned(
    right: 10,
    top: 8,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(size.width * 0.025),
      ),
      child: Icon(
        Icons.handshake,
        size: size.width * 0.1,
        color: Colors.white,
        // shadows: [Shadow(color: Colors.black, blurRadius: 8)],
      ),
    ),
  );

  _contentCard(Size size) => Container(
    width: size.width,
    padding: EdgeInsetsGeometry.all(size.width * 0.02),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
