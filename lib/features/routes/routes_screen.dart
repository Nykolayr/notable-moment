import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/route_tooltip_card.dart';
import 'package:notable_moments/features/routes/edit_routes_screen.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex_map;
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

RouteModel toRouteModel(RouteAdminModel admin) {
  return RouteModel(
    id: admin.id,
    title: admin.title,
    description: admin.description,
    points: admin.points.map((p) {
      return RoutePoint(
        name: p.title, // ← Исправлено: теперь берём название точки
        description: p.description,
        latitude: p.latitude,
        longitude: p.longitude,
        tests: p.tests,
      );
    }).toList(),
    taskCount: admin.points.length,
  );
}

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key, required this.isActive});
  final bool isActive;

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  static const double _collapsedHeightFactor = 0.12;
  static const double _expandedHeightFactor = 0.5;
  bool isExpanded = false;

  yandex_map.MapWindow? mapController; // MapWindow который возвращает AppMap
  int? selectedPointIndex;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _expandPanel();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    mapController = null;
    super.dispose();
  }

  void _expandPanel() {
    _animationController.forward();
    isExpanded = true;
  }

  void _collapsePanel() {
    _animationController.reverse();
    isExpanded = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final fractionDelta = -delta / (screenHeight * (_expandedHeightFactor - _collapsedHeightFactor));
    _animationController.value = (_animationController.value + fractionDelta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _expandPanel();
    } else if (velocity > 300) {
      _collapsePanel();
    } else {
      if (_animationController.value > 0.5) {
        _expandPanel();
      } else {
        _collapsePanel();
      }
    }
  }

  void _drawRoutesAndPoints() {
    final map = mapController!.map;
    map.mapObjects.clear();
    final allRoutes = ref.read(routesProvider).allRoutes;
    final progress = ref.read(progressProvider);
    int globalIndex = 0;
    for (final route in allRoutes) {
      final lastUnlocked = progress.unlockedIndexes[route.id] ?? -1;
      final isRouteOpened = lastUnlocked >= route.points.length - 1;
      final polylineObject = map.addPolyline(route.polyline);
      if (!isRouteOpened) {
        // polylineObject.style.dashPattern = [20, 20]; // пунктир (если поддерживается)
        // polylineObject.style.innerOutlineEnabled = false; // нельзя изменять, только для чтения
        polylineObject.setStrokeColor(const Color(0xFFBCC3CD)); // Серый для закрытых
      } else {
        // polylineObject.style.dashPattern = []; // сплошная
        // polylineObject.style.innerOutlineEnabled = true; // нельзя изменять, только для чтения
        polylineObject.setStrokeColor(const Color(0xFF466BFF)); // Синий для открытых
      }
      for (int i = 0; i < route.points.length; i++) {
        final point = route.points[i].point;
        final isSelected = globalIndex == selectedPointIndex;
        map.addPlacemark(
          point,
          scale: globalIndex == selectedPointIndex ? 1.4 : 1.0,
          onTap: (obj, pt) {
            final pointName = route.points[i].title;
            print('Placemark tapped at index: $globalIndex, name: $pointName');
            setState(() {
              selectedPointIndex = globalIndex;
              _drawRoutesAndPoints();
            });
            return true;
          },
        );
        globalIndex++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final routesState = ref.watch(routesProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = screenHeight * _collapsedHeightFactor;
    final maxHeight = screenHeight * _expandedHeightFactor;

    return AppScaffold(
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      body: Stack(
        children: [
          AppMap(
            onMapCreated: (controller) async {
              if (_mapInitialized) return;
              mapController = controller;
              _mapInitialized = true;
              await Future.delayed(const Duration(milliseconds: 500));
              _drawRoutesAndPoints();
              // fit bounds, если нужно
            },
            disableTaps: false, // Теперь карта интерактивна
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton.icon(
                    icon: AppIcon.plus,
                    onTap: () => mapController?.map.changeZoomWithDelta(1),
                  ),
                  const SizedBox(height: 8),
                  AppButton.icon(
                    icon: AppIcon.minus,
                    onTap: () => mapController?.map.changeZoomWithDelta(-1),
                  ),
                  const SizedBox(height: 8),
                  AppButton.icon(
                    icon: AppIcon.location,
                    onTap: () => mapController?.map.animateToKrasnoyarsk(),
                  ),
                  if (profileState.isAdmin) ...[
                    const SizedBox(height: 8),
                    AppButton.icon(
                      icon: AppIcon.edit,
                      onTap: () {
                        context.push(EditRoutesScreen());
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final height = minHeight + (maxHeight - minHeight) * _animationController.value;
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: child!,
              );
            },
            child: GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: _buildBottomPanel(context, routesState.activeRoutes),
            ),
          ),
          if (selectedRoute != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: RouteTooltipCard(route: selectedRoute),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, List<RouteAdminModel> routes) {
    final query = ref.watch(searchQueryProvider);
    final filtered = routes.where((r) {
      return r.title.toLowerCase().contains(query) || (r.description.toLowerCase()).contains(query);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
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
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value.trim().toLowerCase();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Ничего не найдено'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final route = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedRouteProvider.notifier).state = toRouteModel(route);
                          _collapsePanel();
                        },
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
