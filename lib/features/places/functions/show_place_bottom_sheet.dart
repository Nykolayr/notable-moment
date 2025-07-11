// lib/features/routes/widget/show_place_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_image.dart';
import 'package:notable_moments/features/routes/helpers/map_extension.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/widget/app_map.dart';
import 'package:share_plus/share_plus.dart';

void showPlaceBottomSheet({
  required BuildContext context,
  required PointAdminModel point,
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
              if (point.photos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColor.bgText200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Фотографии места еще нет,\nно скоро появится',
                      style: AppStyle.subtext.bgText500,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (point.photos.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppImage(
                      point.photos[0],
                      width: double.infinity,
                      height: 200,
                      backgroundColor: AppColor.bgText200,
                      loadingSize: 24,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: point.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => AppImage(
                      point.photos[index],
                      borderRadius: 8,
                      width: 300,
                      height: 200,
                      backgroundColor: AppColor.bgText200,
                      loadingSize: 24,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(point.title, style: AppStyle.subheader1.bgText900),
                    const SizedBox(height: 12),
                    Text('г. Красноярск', style: AppStyle.subtext.bgText600),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 324 / 130,
                      child: AppMap(
                        showControls: false,
                        disableTaps: true,
                        onMapCreated: (mapWindow) async {
                          await Future.delayed(const Duration(milliseconds: 300));

                          mapWindow.map.addPlacemark(point.point);
                          mapWindow.map.animateToPoint(point.point, zoom: 15);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(point.description, style: AppStyle.roboto14w400.bgText900),
                    if (point.schedule.periods.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Режим работы', style: AppStyle.subheader2.bgText900),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: point.schedule.periods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final period = point.schedule.periods[index];
                          return Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: Text(
                                  period.daysText,
                                  style: AppStyle.roboto14w400.bgText900,
                                ),
                              ),
                              Text(period.timeText, style: AppStyle.roboto14w400.bgText900),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('Телефон', style: AppStyle.subheader2.bgText900),
                    const SizedBox(height: 12),
                    if (point.phones.isEmpty)
                      Text('Нет доступных', style: AppStyle.roboto14w400.bgText900)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: point.phones.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => AppGestureDetector(
                          onTap: () => context.openTel(point.phones[index]),
                          child: Text(
                            point.phones[index],
                            style: AppStyle.roboto14w400.bgText900,
                          ),
                        ),
                      ),
                    if (point.url.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AppButton(
                        title: 'Поделиться местом',
                        onTap: () {
                          final text = 'Родные штрихи\n${point.title}\n${point.url}';
                          SharePlus.instance.share(
                            ShareParams(text: text),
                          );
                        },
                      ),
                    ],
                    SizedBox(height: context.safeArea.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
