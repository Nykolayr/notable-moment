// lib/features/routes/route_tooltip_card.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/routes/route_map_screen.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';

class RouteTooltipCard extends StatelessWidget {
  final RouteModel route;

  const RouteTooltipCard({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final points = route.points;
    final taskCount = points.fold(0, (sum, point) => sum + point.tests.length);
    return GestureDetector(
      onTap: () {
        context.push(
          RouteMapScreen(route: route),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Маршрут «${route.title}»',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Локаций: ${route.points.length}  Заданий: $taskCount',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
