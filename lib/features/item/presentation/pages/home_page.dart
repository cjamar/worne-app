import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/core/utils/items_helper.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/shared_group.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/item_form_page.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/shared_items_page.dart';
import 'package:prestar_ropa_app/features/item/presentation/widgets/grouped_items_by_user_card.dart';
import 'package:prestar_ropa_app/features/item/presentation/widgets/item_card.dart';
import 'package:prestar_ropa_app/features/shared/widgets/app_drawer.dart';
import 'package:prestar_ropa_app/features/shared/widgets/remove_item_modal.dart';
import 'package:prestar_ropa_app/features/shared/widgets/simple_widgets.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final state = context.read<ItemBloc>().state;
    if (state is! ItemLoadedGrouped) {
      context.read<ItemBloc>().add(LoadItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: EdgeInsets.only(right: size.width * 0.025),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        toolbarHeight: 45,
        leading: Icon(Icons.logo_dev, size: size.width * 0.12),
        actions: [_userArea(size)],
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: _homeBody(size),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: _fab(),
      drawer: AppDrawer(),
    );
  }

  _userArea(Size size) => BlocBuilder<UserBloc, UserState>(
    builder: (context, state) {
      String? avatar;
      if (state is UserLoaded) avatar = state.user.avatarUrl;

      return IconButton(
        padding: EdgeInsets.all(size.width * 0.01),
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: ClipOval(
            child: (avatar != null && avatar.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: avatar,
                    width: size.width * 0.08,
                    height: size.width * 0.08,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SimpleWidgets.loader(),
                    errorWidget: (context, url, error) =>
                        SimpleWidgets.placeholderImage(
                          size,
                          Icons.broken_image,
                        ),
                  )
                : SimpleWidgets.placeholderAvatar(
                    size,
                    Icons.person_2_outlined,
                  ),
          ),
        ),
      );
    },
  );

  _fab() => FloatingActionButton(
    backgroundColor: Colors.black,
    elevation: 0,
    shape: BeveledRectangleBorder(
      side: BorderSide(width: 0.5, color: Colors.white),
    ),

    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemFormPage()),
    ),
    child: Icon(Icons.add, color: Colors.white),
  );

  _homeBody(Size size) => SizedBox(
    width: size.width,
    height: size.height,
    child: BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemSharedSuccess) {
          SimpleWidgets.snackbar(context, state.message, Colors.blue);
        } else if (state is ItemSharedError) {
          SimpleWidgets.snackbar(context, state.message, Colors.red);
        }
      },
      child: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return SimpleWidgets.loader();
          }
          if (state is ItemError) {
            return _errorContainer(size, state.message);
          }
          if (state is ItemLoadedGrouped) {
            return _tabView(size, state); // items propios + items compartidos
          }
          // Cualquier otro estado que no sea ItemLoadedGrouped
          return _undefinedErrorContainer(size);
        },
      ),
    ),
  );

  _tabView(Size size, ItemLoadedGrouped state) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          tabs: [_tabTitle('Mis items'), _tabTitle('Items compartidos')],
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
        ),
        Expanded(
          child: TabBarView(
            children: [
              _tabViewOwnItems(size, state),
              _tabViewSharedItems(size, state),
            ],
          ),
        ),
      ],
    ),
  );

  _tabTitle(String text) => Tab(text: text);

  _tabViewOwnItems(Size size, ItemLoadedGrouped state) => state.ownItems.isEmpty
      ? _emptyOwnListContainer(size)
      : _ownItemsList(size, state.ownItems);

  _tabViewSharedItems(Size size, ItemLoadedGrouped state) =>
      state.groupedSharedItems.isEmpty
      ? _emptySharedListContainer(size)
      : _sharedItemsList(size, state.groupedSharedItems);

  _sharedItemsList(Size size, Map<String, SharedGroup> groupsByUserItems) =>
      ListView.builder(
        itemCount: groupsByUserItems.length,
        itemBuilder: (context, index) {
          final entry = groupsByUserItems.entries.elementAt(index);
          final otherUserId = entry.key; // ✅ sigue siendo la key
          final sharedGroup = entry.value; // ✅ ahora entry.value es SharedGroup
          final itemsList = sharedGroup.items; // ✅ lista de items del grupo
          final userName =
              sharedGroup.nameUserB ??
              'Usuario'; // ✅ el username del otro usuario

          if (itemsList.isEmpty) return SizedBox.shrink();

          return GroupedItemsByUserCard(
            groupByUser: groupsByUserItems,
            index: index,
            onTap: () => _goToSharedItem(userName, itemsList, otherUserId),
          );
        },
      );

  // _itemListBody(Size size, ItemLoadedGrouped state) => CustomScrollView(
  //   slivers: [
  //     // Botonera de filtros
  //     _filterItemListButton(size, state.activeFilter),

  //     // Si no hay nada, mostramos mensaje
  //     if (state.ownItems.isEmpty && state.groupedSharedItems.isEmpty)
  //       SliverFillRemaining(
  //         hasScrollBody: false,
  //         child: _emptyListContainer(size),
  //       )
  //     else ...[
  //       // Mis items propios
  //       if (state.ownItems.isNotEmpty) _itemList(size, state.ownItems),

  //       // Cada grupo de items compartidos por usuario
  //       ...state.groupedSharedItems.entries.expand((entry) {
  //         final userName = entry.key;
  //         final itemsList = entry.value;

  //         return [
  //           // Título del grupo
  //           SliverToBoxAdapter(
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 16,
  //                 vertical: 6,
  //               ),
  //               child: Text(
  //                 'Compartido con $userName',
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           // Grid de items del grupo
  //           _itemList(size, itemsList),
  //         ];
  //       }),
  //     ],
  //   ],
  // );

  _filterItemListButton(Size size, ItemStatus? activeFilter) => SliverAppBar(
    automaticallyImplyLeading: false,
    floating: true,
    snap: true,
    pinned: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    toolbarHeight: size.height * 0.06,
    title: SizedBox(
      width: size.width,
      height: size.height * 0.04,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ItemStatusFilter.filtersItem.map<Widget>((filter) {
          final status = ItemsHelper.mapStringToStatus(filter);
          final isActive = activeFilter == status;
          return _filterButton(size, filter, isActive);
        }).toList(),
      ),
    ),
  );

  _filterButton(Size size, String filter, bool isActive) => InkWell(
    onTap: () => _filteringItems(filter),
    child: Container(
      margin: EdgeInsets.only(right: size.width * 0.025),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.width * 0.015,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.white,
        border: Border.all(width: 0.5),
      ),
      child: Text(
        filter,
        style: TextStyle(
          fontSize: 15,
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    ),
  );

  _ownItemsList(Size size, List<Item> items) => GridView.builder(
    shrinkWrap: true,
    itemCount: items.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
    ),
    itemBuilder: (context, index) => ItemCard(
      key: ValueKey(items[index].id),
      item: items[index],
      onTap: () => _goToDetail(items[index]),
      onLongPress: () => _confirmDeleteDialog(size, items[index]),
    ),
  );

  // _itemList(Size size, List<Item> items) => SliverPadding(
  //   padding: EdgeInsetsGeometry.all(size.width * 0.01),
  //   sliver: SliverGrid(
  //     delegate: SliverChildBuilderDelegate(
  //       (context, index) => ItemCard(
  //         key: ValueKey(items[index].id),
  //         item: items[index],
  //         onTap: () => _goToDetail(items[index]),
  //         onLongPress: () => _confirmDeleteDialog(size, items[index]),
  //       ),
  //       childCount: items.length,
  //     ),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       childAspectRatio: 0.75,
  //     ),
  //   ),
  // );

  _goToDetail(Item item) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );

  Future<void> _confirmDeleteDialog(Size size, Item item) async {
    final confirmed = await RemoveItemModal.showConfirmDialog(
      context: context,
      title: 'Eliminar item',
      content: '¿Deseas eliminar "${item.name}"?',
      confirmText: 'Eliminar',
    );
    if (confirmed == true) _deleteItem(item);
  }

  _deleteItem(Item item) => context.read<ItemBloc>().add(DeleteEvent(item));

  _filteringItems(String filterName) {
    final bloc = context.read<ItemBloc>();

    switch (filterName) {
      case 'Todos':
        bloc.add(FilterItems(null));
        break;
      case 'Disponibles':
        bloc.add(FilterItems(ItemStatus.available));
        break;
      case 'Prestados':
        bloc.add(FilterItems(ItemStatus.loaned));
        break;
      case 'Reservados':
        bloc.add(FilterItems(ItemStatus.reserved));
        break;
      default:
        bloc.add(FilterItems(null));
    }
  }

  _goToSharedItem(String userName, List<Item> itemsList, String otherUserId) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SharedItemsPage(
            username: userName,
            items: itemsList,
            otherUserId: otherUserId,
          ),
        ),
      );

  _emptyOwnListContainer(Size size) => SimpleWidgets.containerWithIcon(
    size,
    Icons.auto_awesome,
    'Aún no tienes ningún producto, \n ¡añádelo a la lista!',
  );

  _emptySharedListContainer(Size size) => SimpleWidgets.containerWithIcon(
    size,
    Icons.handshake,
    'Aún no tienes ningún producto compartido, \n ¡comparte items con usuarios amigos!',
  );

  _errorContainer(Size size, String message) => SimpleWidgets.containerWithIcon(
    size,
    Icons.error,
    'Ha ocurrido un error, \n $message',
  );

  _undefinedErrorContainer(Size size) => SimpleWidgets.containerWithIcon(
    size,
    Icons.warning_rounded,
    'Ha ocurrido un estado inesperado, \n reinicia la aplicación',
  );
}
