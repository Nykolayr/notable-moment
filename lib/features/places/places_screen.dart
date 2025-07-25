import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/places/functions/show_place_bottom_sheet.dart';
import 'package:notable_moments/features/routes/provider/routes_provider.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlaces = ref
        .watch(routesProvider)
        .activeRoutes
        .map(
          (route) {
            return route.points
                .where((point) => !point.isDraft && point.photos.isNotEmpty)
                .map((point) => (route, point));
          },
        )
        .flattened
        .toList();

    return SafeArea(
      child: AppScaffold(
        appBar: AppAppBar(title: 'Открытые места', hideLeading: true),
        body: (() {
          final filteredPlaces = activePlaces
              .where((data) =>
                  data.$2.photos.isNotEmpty && !data.$2.photos.first.contains('https://firebasestorage.googleapis.com'))
              .toList();
          if (filteredPlaces.isEmpty) {
            return const Center(
              child: Text('Ещё нет фото для мест', style: TextStyle(fontSize: 18)),
            );
          }
          return GridView.count(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 158 / 213,
            children: filteredPlaces.map(
              (data) {
                final (route, point) = data;
                return AppGestureDetector(
                  onTap: () => showPlaceBottomSheet(
                    context: context,
                    point: point,
                    routeTitle: route.title,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColor.bgText200, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AppImage(point.photos.first, backgroundColor: AppColor.bgText00),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            point.title,
                            style: AppStyle.subtext.bgText900,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          );
        })(),
      ),
    );
  }
}
