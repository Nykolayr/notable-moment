// lib/features/routes/widget/show_place_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/places/widgets/photo_carousel_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class PlaceMapWidget extends StatefulWidget {
  final RoutePoint point;

  const PlaceMapWidget({
    super.key,
    required this.point,
  });

  @override
  State<PlaceMapWidget> createState() => _PlaceMapWidgetState();
}

class _PlaceMapWidgetState extends State<PlaceMapWidget> {
  YandexMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: YandexMap(
          mapObjects: [
            PlacemarkMapObject(
              mapId: const MapObjectId('place_placemark'),
              point: Point(latitude: widget.point.latitude!, longitude: widget.point.longitude!),
              opacity: 1,
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage('assets/placemark/opened.png'),
                  scale: 1,
                ),
              ),
            ),
          ],
          onMapCreated: (controller) async {
            mapController = controller;
            // Центрируем карту на точке места
            await controller.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: Point(latitude: widget.point.latitude!, longitude: widget.point.longitude!),
                  zoom: 15,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void showPlaceBottomSheet({
  required BuildContext context,
  required RoutePoint point,
  required String routeTitle,
}) =>
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColor.bgText00,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 36,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColor.bgText500,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Карусель фотографий места
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PhotoCarouselWidget(
                  photos: point.photos,
                  height: 200,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(point.name, style: AppStyle.subheader1.bgText900),
                    const SizedBox(height: 12),
                    Text('г. Красноярск', style: AppStyle.subtext.bgText600),
                    const SizedBox(height: 12),
                    // Кастомная карта с кнопками управления
                    PlaceMapWidget(point: point),
                    const SizedBox(height: 12),
                    Text(point.description ?? '', style: AppStyle.roboto14w400.bgText900),
                    const SizedBox(height: 12),
                    Text('Телефон', style: AppStyle.subheader2.bgText900),
                    const SizedBox(height: 12),
                    Text('Нет доступных', style: AppStyle.roboto14w400.bgText900),
                    const SizedBox(height: 12),
                    AppButton(
                      title: 'Поделиться местом',
                      onTap: () {
                        final name = point.name;
                        final text = 'Родные штрихи\n$name\n';
                        SharePlus.instance.share(
                          ShareParams(text: text),
                        );
                      },
                    ),
                    SizedBox(height: context.safeArea.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
