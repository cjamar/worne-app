import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/features/shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';

class ItemsCollage extends StatelessWidget {
  final List<Item> items;
  final double width;

  const ItemsCollage({super.key, required this.items, required this.width});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final images = items
        .take(4)
        .map((e) => e.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    return SizedBox(
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          final image = index < images.length ? images[index] : null;
          return _imageContainer(image, size);
        },
      ),
    );
  }

  _imageContainer(String? image, Size size) => ClipRRect(
    borderRadius: BorderRadius.circular(width * 0.12),
    child: Container(
      margin: EdgeInsets.all(width * 0.02),
      color: image == null ? Colors.grey.shade300 : null,
      child: image != null
          ? CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              memCacheWidth: 300,
              placeholder: (context, url) => SimpleWidgets.loader(),
              errorWidget: (context, url, error) =>
                  SimpleWidgets.placeholderImage(size, Icons.broken_image),
            )
          : Container(color: Colors.grey.shade200),
    ),
  );
}
