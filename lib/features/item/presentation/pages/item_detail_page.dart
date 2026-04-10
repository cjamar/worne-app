import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/item_form_page.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/items_helper.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppStyles.whiteColor,
      appBar: AppBar(
        toolbarHeight: size.height * 0.0,
        backgroundColor: AppStyles.primaryColor,
      ),
      body: _itemDetailBody(size, context),
    );
  }

  _itemDetailBody(Size size, BuildContext context) => CustomScrollView(
    slivers: [_sliverAppBar(size, context), _sliverContent(size, context)],
  );

  _sliverAppBar(Size size, BuildContext context) => SliverAppBar(
    expandedHeight: size.height * 0.5,
    pinned: true,
    backgroundColor: Colors.transparent,
    elevation: 0,

    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light, // iOS (fondo claro)
      statusBarIconBrightness: Brightness.dark, // Android
    ),
    leading: IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: AppStyles.whiteColor,
        size: AppStyles.iconSize1(size),
      ),
      onPressed: () => Navigator.pop(context),
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.edit,
          color: AppStyles.whiteColor,
          size: AppStyles.iconSize1(size),
        ),
        onPressed: () => _goToEdit(context),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          item.imageUrl.trim().isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SimpleWidgets.loader(),
                  errorWidget: (context, url, error) =>
                      SimpleWidgets.placeholderImage(size, Icons.broken_image),
                )
              : SimpleWidgets.placeholderImage(size, Icons.auto_awesome),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  _sliverContent(Size size, BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(
      width: size.width * 0.9,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(),
            SizedBox(height: size.height * 0.01),
            _categoryAndStatus(size),
            SizedBox(height: size.height * 0.04),
            _description(),
            SizedBox(height: size.height * 0.1),
            _deleteButton(size, context),
          ],
        ),
      ),
    ),
  );

  _title() => Text(
    item.name,
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  );

  _categoryAndStatus(Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [_category(), _statusChip(size)],
  );

  _category() => Text(
    item.category,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppStyles.primaryColor,
    ),
  );

  _statusChip(Size size) {
    Color color = ItemsHelper.colorStatus(item);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.width * 0.005,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Text(item.status.name, style: TextStyle(color: color)),
    );
  }

  _description() => Text(item.description, style: TextStyle(fontSize: 14));

  _deleteButton(Size size, BuildContext context) => Container(
    width: size.width * 0.9,
    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
    child: TextButton(
      style: TextButton.styleFrom(
        side: BorderSide(color: AppStyles.alertColor, width: 0.5),
        foregroundColor: AppStyles.alertColor,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      ),
      onPressed: () => _deleteItem(),

      child: const Text('Eliminar producto'),
    ),
  );

  void _goToEdit(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );

  void _deleteItem() {}
}
