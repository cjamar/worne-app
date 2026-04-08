
/// EXPERIMENTAL: versión con Slivers para filtros colapsables.
/// Pendiente de reintroducir cuando se rediseñe la Home.
/// No esta claro si se reintroducirá

 // NO BORRAR!!!! SE USARÁ PROXIMAMENTE
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


    //  SliverAppBar(
  //   automaticallyImplyLeading: false,
  //   floating: true,
  //   snap: true,
  //   pinned: false,
  //   scrolledUnderElevation: 0,
  //   backgroundColor: Colors.white,
  //   toolbarHeight: size.height * 0.06,
  //   title: SizedBox(
  //     width: size.width,
  //     height: size.height * 0.04,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       children: ItemStatusFilter.filtersItem.map<Widget>((filter) {
  //         final status = ItemsHelper.mapStringToStatus(filter);
  //         final isActive = activeFilter == status;
  //         return _filterButton(size, filter, isActive);
  //       }).toList(),
  //     ),
  //   ),
  // );
