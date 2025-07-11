import 'package:flutter_svg/svg.dart';

abstract class AppSvg {
  static const String logo = 'assets/svg/logo.svg';
  static const String onboarding1 = 'assets/svg/onboarding1.svg';
  static const String onboarding2_1 = 'assets/svg/onboarding2_1.svg';
  static const String onboarding2_2 = 'assets/svg/onboarding2_2.svg';
  static const String onboarding3 = 'assets/svg/onboarding3.svg';
  static const String avatar1 = 'assets/svg/avatar1.svg';
  static const String avatar2 = 'assets/svg/avatar2.svg';
  static const String avatar3 = 'assets/svg/avatar3.svg';
  static const String avatar4 = 'assets/svg/avatar4.svg';
  static const String avatar5 = 'assets/svg/avatar5.svg';
  static const String avatar6 = 'assets/svg/avatar6.svg';
  static const String avatar7 = 'assets/svg/avatar7.svg';
  static const String avatar8 = 'assets/svg/avatar8.svg';

  static const List<String> avatars = [avatar1, avatar2, avatar3, avatar4, avatar5, avatar6, avatar7, avatar8];
}

extension SvgImageExtension on String {
  SvgPicture get svgPricture => SvgPicture.asset(this);
}
