import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class RouteSearchModal extends ConsumerStatefulWidget {
  final void Function(RouteModel) onRouteTap;
  final ScrollController? scrollController;
  final DraggableScrollableController? controllerDrag;

  const RouteSearchModal({
    super.key,
    required this.onRouteTap,
    required this.scrollController,
    required this.controllerDrag,
  });

  @override
  ConsumerState<RouteSearchModal> createState() => _RouteSearchModalState();
}

class _RouteSearchModalState extends ConsumerState<RouteSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _searchController.addListener(() => setState(() {}));
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.controllerDrag?.animateTo(0.9, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<RouteAdminModel> get _filteredRoutes {
    final routes = ref.watch(routesProvider).allRoutes;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return routes;
    return routes
        .where((r) => r.title.toLowerCase().contains(query) || r.description.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _filteredRoutes;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SafeArea(
        top: false,
        child: ListView.builder(
          controller: widget.scrollController,
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 2 + (filteredRoutes.isEmpty ? 1 : filteredRoutes.length),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Drag handle
              return Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }
            if (index == 1) {
              // Search field
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    hintText: 'Найти маршрут',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey.shade600),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _focusNode.requestFocus();
                            },
                          )
                        : null,
                  ),
                ),
              );
            }

            if (filteredRoutes.isEmpty) {
              // No routes found
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Маршруты не найдены')),
              );
            }
            final route = filteredRoutes[index - 2];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _RouteCard(
                route: route,
                onTap: () async {
                  final convertedRoutes = ref.read(convertedRoutesProvider);
                  RouteModel? routeModel = convertedRoutes[route.id];

                  if (routeModel == null) {
                    Logger.w('route_search_modal: Маршрут ${route.id} не найден в кэше');
                    return;
                  }

                  widget.onRouteTap(routeModel);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteAdminModel route;
  final VoidCallback onTap;
  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Локаций: ${route.points.length}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (route.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  route.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
