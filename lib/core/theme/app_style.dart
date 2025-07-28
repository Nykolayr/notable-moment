import 'package:flutter/widgets.dart';
import 'package:notable_moments/core/theme/app_color.dart';

abstract class AppStyle {
  static const TextStyle suslik = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    height: 16 / 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle roboto11w500 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    height: 13.75 / 11,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle roboto14w400 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    height: 17.5 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle roboto14w500 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    height: 17.5 / 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle roboto14w700 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    height: 17.5 / 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle roboto18w700 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle roboto22w700 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 22,
    height: 26.4 / 22,
    fontWeight: FontWeight.w700,
  );

  //
  static const TextStyle headline = roboto22w700;
  static const TextStyle body = roboto14w400;
  static const TextStyle subheader1 = roboto18w700;
  static const TextStyle subheader2 = roboto14w700;
  static const TextStyle subtext = roboto11w500;
}

extension ColorTextStyleExtension on TextStyle {
  TextStyle get h1 => copyWith(height: 1);
  //
  TextStyle get primary => copyWith(color: AppColor.primary);
  TextStyle get error => copyWith(color: AppColor.error);
  TextStyle get bgText00 => copyWith(color: AppColor.bgText00);
  TextStyle get bgText200 => copyWith(color: AppColor.bgText200);
  TextStyle get bgText500 => copyWith(color: AppColor.bgText500);
  TextStyle get bgText600 => copyWith(color: AppColor.bgText600);
  TextStyle get bgText900 => copyWith(color: AppColor.bgText900);
}
