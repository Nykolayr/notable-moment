import 'package:notable_moments/core/theme/app_images.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class AppMapData {
  static const krasnoyarskPoint = Point(latitude: 56.0267294, longitude: 92.865734);

  static BitmapDescriptor fromAsset(String assetName, {int size = 36 * 2}) {
    return BitmapDescriptor.fromAssetImage(assetName);
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
