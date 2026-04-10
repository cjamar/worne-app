import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/item_form_page.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/items_helper.dart';
import '../../../shared/widgets/remove_item_modal.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppStyles.whiteColor,
      body: _itemDetailBody(size, context),
    );
  }

  _itemDetailBody(Size size, BuildContext context) =>
      BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is! ItemLoadedGrouped) return SimpleWidgets.loader();

          final item = _findItem(state, itemId);
          if (item == null) {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pop(context);
              }
            });

            return const SizedBox();
          }

          return CustomScrollView(
            slivers: [
              _sliverAppBar(size, context, item),
              _sliverContent(size, context, item),
            ],
          );
        },
      );

  Item? _findItem(ItemLoadedGrouped state, String itemId) {
    for (final item in state.allItems) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  _sliverAppBar(Size size, BuildContext context, Item item) => SliverAppBar(
    expandedHeight: size.height * 0.5,
    pinned: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
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
        onPressed: () => _goToEdit(context, item),
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
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  _sliverContent(Size size, BuildContext context, Item item) =>
      SliverToBoxAdapter(
        child: SizedBox(
          width: size.width * 0.9,
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(item.name),
                SizedBox(height: size.height * 0.01),
                _categoryAndStatus(size, item),
                SizedBox(height: size.height * 0.04),
                _description(item.description),
                SizedBox(height: size.height * 0.1),
                _deleteButton(size, context, item),
              ],
            ),
          ),
        ),
      );

  _title(String name) =>
      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold));

  _categoryAndStatus(Size size, Item item) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [_category(item.category, size), _statusChip(size, item)],
  );

  _category(String category, Size size) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size.width * 0.05),
      border: Border.all(color: AppStyles.secondaryColor, width: 2),
    ),
    padding: EdgeInsets.symmetric(
      vertical: size.width * 0.01,
      horizontal: size.width * 0.03,
    ),
    child: Text(
      category,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppStyles.primaryColor,
      ),
    ),
  );

  _statusChip(Size size, Item item) {
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

  _description(String description) =>
      Text(description, style: TextStyle(fontSize: 14));

  _deleteButton(Size size, BuildContext context, Item item) => Container(
    width: size.width * 0.9,
    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
    child: TextButton(
      style: TextButton.styleFrom(
        side: BorderSide(color: AppStyles.alertColor, width: 0.5),
        foregroundColor: AppStyles.alertColor,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      ),
      onPressed: () => _confirmDeleteDialog(size, context, item),

      child: const Text('Eliminar producto'),
    ),
  );

  Future<void> _confirmDeleteDialog(
    Size size,
    BuildContext context,
    Item item,
  ) async {
    final confirmed = await RemoveItemModal.showConfirmDialog(
      context: context,
      title: 'Eliminar prenda',
      content: '¿Deseas eliminar "${item.name}"?',
      confirmText: 'Eliminar',
    );
    if (confirmed == true && context.mounted) _deleteItem(context, item);
  }

  _goToEdit(BuildContext context, Item item) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );

  _deleteItem(BuildContext context, Item item) =>
      context.read<ItemBloc>().add(DeleteEvent(item));
}
