import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/edit_route_screen.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';
import 'package:notable_moments/features/routes/widget/route_widget.dart';

class EditRoutesScreen extends ConsumerWidget {
  const EditRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider).allRoutes;
    return AppScaffold(
      appBar: AppAppBar(
        title: 'Редактирование маршрутов',
        actions: [
          AppButton.icon(
            icon: AppIcon.plus,
            onTap: () => context.push(EditRouteScreen(routeId: null)),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: routes.length,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        onReorder: (oldIndex, newIndex) => ref.read(routesProvider.notifier).reorderRoutes(oldIndex, newIndex),
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final elevation = Curves.easeInOut.transform(animation.value);
              return Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(8),
                child: RouteWidget(route: routes[index]),
              );
            },
          );
        },
        itemBuilder: (context, index) {
          final route = routes[index];
          return Padding(
            key: ValueKey(route.id),
            padding: const EdgeInsets.only(bottom: 4),
            child: RouteWidget(
              route: route,
            ),
          );
        },
      ),
    );
  }
}
