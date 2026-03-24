import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/core/utils/items_helper.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/item_form_page.dart';
import 'package:prestar_ropa_app/features/item/presentation/widgets/item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> filtersItem = [
    'Todos',
    'Disponibles',
    'Prestados',
    'Reservados',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(LoadItems());
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
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
    );
  }

  _userArea(Size size) => CircleAvatar(
    backgroundColor: Colors.grey.shade300,
    child: Icon(
      Icons.person_2_outlined,
      size: size.width * 0.07,
      color: Colors.blueGrey,
    ),
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
    child: BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is ItemError) {
          return _errorContainer(size, state.message);
        }
        if (state is ItemLoaded) {
          if (state.items.isEmpty) {
            return _emptyContainer(size);
          }
          return _itemListBody(size, state);
        }
        return const SizedBox.shrink();
      },
    ),
  );

  _errorContainer(Size size, String message) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error),
          Text('Ha ocurrido un error, $message', textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  _emptyContainer(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.3,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox),
          Text('Aún no tienes ningún producto, ¡añádelo a la lista!'),
        ],
      ),
    ),
  );

  _itemListBody(Size size, ItemLoaded state) => CustomScrollView(
    slivers: [
      _filterItemListButton(size, state.activeFilter),
      _itemList(size, state.items),
    ],
  );

  _filterItemListButton(Size size, ItemStatus? activeFilter) => SliverAppBar(
    floating: true,
    snap: true,
    pinned: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    toolbarHeight: size.height * 0.06,
    title: SizedBox(
      height: size.height * 0.04,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filtersItem.map<Widget>((filter) {
          final status = ItemsHelper.mapStringToStatus(filter);
          final isActive = activeFilter == status;
          return _filterButton(size, filter, isActive);
        }).toList(),
        //  filtersItem
        //     .map<Widget>((filter) => _filterButton(size, filter, isActive))
        //     .toList(),
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

  _itemList(Size size, List<Item> items) => SliverPadding(
    padding: EdgeInsetsGeometry.all(size.width * 0.01),
    sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ItemCard(
          item: items[index],
          onTap: () => _goToDetail(items[index]),
          onLongPress: () => _confirmDeleteDialog(size, items[index].id!),
        ),
        childCount: items.length,
      ),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
    ),
  );

  _goToDetail(Item item) => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
  );

  Future<void> _confirmDeleteDialog(Size size, String itemId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar item'),
        content: const Text('¿Deseas eliminar este producto?'),
        actions: [
          _textButtonDialog(
            size,
            'Cancelar',
            Colors.grey.shade400,
            Colors.black,
            false,
          ),
          _textButtonDialog(
            size,
            'Eliminar',
            Colors.redAccent,
            Colors.white,
            true,
          ),
        ],
      ),
    );
    if (confirmed == true) _deleteItem(itemId);
  }

  _textButtonDialog(
    Size size,
    String action,
    Color backgroundColor,
    Color foregroundColor,
    bool confirmButton,
  ) => TextButton(
    onPressed: () => Navigator.pop(context, confirmButton),
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.06),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    ),
    child: Text(action),
  );

  _deleteItem(String itemId) =>
      context.read<ItemBloc>().add(DeleteEvent(itemId));

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
}
