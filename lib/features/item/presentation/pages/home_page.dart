import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/core/theme/app_styles.dart';
import '../../../../core/utils/items_helper.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/remove_item_modal.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_status.dart';
import '../../domain/entities/shared_group.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';
import '../widgets/grouped_items_by_user_card.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'item_form_page.dart';
import 'shared_items_page.dart';

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
        backgroundColor: AppStyles.whiteColor,
        scrolledUnderElevation: 0,
        toolbarHeight: size.height * 0.05,
        // leading: Icon(Icons.logo_dev, size: size.width * 0.12),
        centerTitle: false,
        title: Image(
          image: AssetImage('assets/images/logo1.png'),
          width: size.width * 0.25,
        ),
        actions: [_userArea(size)],
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: _homeBody(size),
      ),
      backgroundColor: AppStyles.whiteColor,
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
          backgroundColor: AppStyles.greyColor300,
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
    backgroundColor: AppStyles.primaryColor,
    shape: CircleBorder(
      side: BorderSide(color: AppStyles.whiteColor, width: 1.6),
    ),
    elevation: 0,
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemFormPage()),
    ),
    child: Icon(Icons.add, color: AppStyles.whiteColor),
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
            return _tabView(size, state);
          }
          return _undefinedErrorContainer(size);
        },
      ),
    ),
  );

  _tabView(Size size, ItemLoadedGrouped state) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppStyles.greyColor200,
            borderRadius: BorderRadius.circular(size.width * 0.06),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: size.width * 0.02,
            vertical: size.height * 0.01,
          ),
          child: TabBar(
            tabs: [_tabTitle('Mis prendas'), _tabTitle('Prendas Compartidas')],
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppStyles.whiteColor,
            unselectedLabelColor: AppStyles.blackColor,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: AppStyles.primaryColor,
              borderRadius: BorderRadius.circular(size.width * 0.06),
            ),
          ),
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

  _tabTitle(String text) => Tab(child: Text(text));

  _tabViewOwnItems(Size size, ItemLoadedGrouped state) => Column(
    children: [
      _filterItemListButton(size, state.activeFilter),
      Expanded(
        child: state.ownItems.isEmpty
            ? _emptyOwnListContainer(size)
            : _ownItemsList(size, state.ownItems),
      ),
    ],
  );

  _tabViewSharedItems(Size size, ItemLoadedGrouped state) =>
      state.groupedSharedItems.isEmpty
      ? _emptySharedListContainer(size)
      : _sharedItemsList(size, state.groupedSharedItems);

  _sharedItemsList(Size size, Map<String, SharedGroup> groupsByUserItems) =>
      ListView.builder(
        itemCount: groupsByUserItems.length,
        itemBuilder: (context, index) {
          final entry = groupsByUserItems.entries.elementAt(index);
          final otherUserId = entry.key;
          final sharedGroup = entry.value;
          final itemsList = sharedGroup.items;
          final userName = sharedGroup.nameUserB ?? 'Usuario';

          if (itemsList.isEmpty) return SizedBox.shrink();

          return GroupedItemsByUserCard(
            groupByUser: groupsByUserItems,
            index: index,
            onTap: () => _goToSharedItem(userName, itemsList, otherUserId),
          );
        },
      );

  _filterItemListButton(Size size, ItemStatus? activeFilter) => Container(
    margin: EdgeInsets.symmetric(
      vertical: size.height * 0.01,
      horizontal: size.width * 0.02,
    ),
    height: size.height * 0.04,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: ItemStatusFilter.filtersItem.map<Widget>((filter) {
        final status = ItemsHelper.mapStringToStatus(filter);
        final isActive = activeFilter == status;
        return _filterButton(size, filter, isActive);
      }).toList(),
    ),
  );

  _filterButton(Size size, String filter, bool isActive) => GestureDetector(
    onTap: () => _filteringItems(filter),
    child: Container(
      margin: EdgeInsets.only(right: size.width * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.width * 0.015,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppStyles.primaryLightColor : AppStyles.greyColor200,
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Text(
        filter,
        style: TextStyle(
          color: isActive ? AppStyles.primaryDarkColor : AppStyles.blackColor,
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

  Future<void> _confirmDeleteDialog(Size size, Item item) async {
    final confirmed = await RemoveItemModal.showConfirmDialog(
      context: context,
      title: 'Eliminar prenda',
      content: '¿Deseas eliminar "${item.name}"?',
      confirmText: 'Eliminar',
    );
    if (confirmed == true) _deleteItem(item);
  }

  // VA AL FORM, NO AL DETALLE DE LECTURA
  // _goToDetail(Item item) => Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  // );

  // VA A LA PAGINA DETALLE DE LECTURA
  _goToDetail(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailPage(itemId: item.id!)),
    );
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
