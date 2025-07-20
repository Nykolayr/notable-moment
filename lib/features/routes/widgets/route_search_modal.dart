import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

/// Оптимизированное модальное окно для поиска маршрутов
class RouteSearchModal extends StatefulWidget {
  final List<RouteAdminModel> routes;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final void Function(RouteModel) onRouteTap;

  const RouteSearchModal({
    super.key,
    required this.routes,
    required this.searchController,
    required this.focusNode,
    required this.onRouteTap,
  });

  @override
  State<RouteSearchModal> createState() => _RouteSearchModalState();
}

class _RouteSearchModalState extends State<RouteSearchModal> {
  String _query = '';
  List<RouteAdminModel> _filteredRoutes = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredRoutes = List.from(widget.routes);

    // Устанавливаем начальный фокус на поле поиска
    widget.focusNode.requestFocus();

    // Подписываемся на изменения текста в поле поиска
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final query = widget.searchController.text.trim().toLowerCase();
      if (query == _query) return;

      setState(() {
        _query = query;
        if (query.isEmpty) {
          _filteredRoutes = List.from(widget.routes);
        } else {
          _filteredRoutes = widget.routes.where((r) {
            return r.title.toLowerCase().contains(query) || r.description.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: widget.searchController,
                    focusNode: widget.focusNode,
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
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filteredRoutes.isEmpty
                      ? const Center(child: Text('Ничего не найдено'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredRoutes.length,
                          itemBuilder: (context, index) {
                            final route = _filteredRoutes[index];
                            return RouteCard(
                              route: route,
                              onTap: () => widget.onRouteTap(_toRouteModel(route)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Используем метод расширения из route_admin_model.dart
  RouteModel _toRouteModel(RouteAdminModel admin) {
    return admin.toRouteModel();
  }
}

// Выделяем карточку маршрута в отдельный виджет для оптимизации
class RouteCard extends StatelessWidget {
  final RouteAdminModel route;
  final VoidCallback onTap;

  const RouteCard({super.key, required this.route, required this.onTap});

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
