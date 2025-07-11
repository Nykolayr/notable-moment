import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_button_delete_dialog.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/features/routes/edit_route_screen.dart';
import 'package:notable_moments/features/routes/model/route_admin_model.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';

class RouteWidget extends ConsumerWidget {
  const RouteWidget({super.key, required this.route});

  final RouteAdminModel route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppGestureDetector(
      onTap: () => context.push(EditRouteScreen(routeId: route.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: route.isDraft ? AppColor.orange.withValues(alpha: .1) : AppColor.bgText200,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    style: AppStyle.subheader2.copyWith(color: route.isDraft ? AppColor.bgText500 : AppColor.bgText900),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Локаций: ${route.visiblePoints} ${route.draftPoints > 0 ? '+ ${route.draftPoints} черн.' : ''}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppButton.icon(
              icon: AppIcon.trash,
              onTap: () => appButtonDeleteDialog(
                title: 'Удалить маршрут',
                description: 'Вы уверены что хотите удалить маршрут',
                context: context,
                okCallBack: () => ref.read(routesProvider.notifier).removeRoute(route),
              ),
              style: AppButtonStyle.red,
            ),
          ],
        ),
      ),
    );
  }
}
