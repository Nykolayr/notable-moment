import 'package:flutter/widgets.dart';
import 'package:notable_moments/core/theme/app_images.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/image.dart' as image_provider;

abstract class AppMapData {
  static const krasnoyarskPoint = Point(latitude: 56.0267294, longitude: 92.865734);

  static image_provider.ImageProvider fromAsset(String assetName, {int size = 36 * 2}) {
    return image_provider.ImageProvider.fromImageProvider(
      ResizeImage(
        AssetImage(AppImages.placemarkBeginClosed),
        width: size,
        height: size,
      ),
    );
  }

  static final placemarkBeginOpened = AppMapData.fromAsset(AppImages.placemarkBeginOpened);
  static final placemarkBeginClosed = AppMapData.fromAsset(AppImages.placemarkBeginClosed);
  static final placemarkEndOpened = AppMapData.fromAsset(AppImages.placemarkEndOpened);
  static final placemarkEndClosed = AppMapData.fromAsset(AppImages.placemarkEndClosed);
  static final placemarkOpened = AppMapData.fromAsset(AppImages.placemarkOpened);
  static final placemarkClosed = AppMapData.fromAsset(AppImages.placemarkClosed);
  static final placemarkAnother = AppMapData.fromAsset(AppImages.placemarkAnother);
  static final placemarkSelected = AppMapData.fromAsset(AppImages.placemarkSelected);
}
