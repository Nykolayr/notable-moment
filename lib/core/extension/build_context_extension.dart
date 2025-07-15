// lib/core/extension/build_context_extension.dart

import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

extension BuildContextExtension on BuildContext {
  /// Удобный доступ к MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;
  EdgeInsets get safeArea => mediaQuery.padding;

  /// Быстрые навигационные методы
  Future<T?> pushReplacement<T>(Widget page) =>
      Navigator.of(this).pushReplacement(MaterialPageRoute<T>(builder: (_) => page));

  void pop<T>([T? result]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop<T>(result);
    }
  }

  Future<T?> push<T>(Widget page) => Navigator.of(this).push(MaterialPageRoute<T>(builder: (_) => page));

  /// Снять фокус с клавиатуры
  void unfocus() => FocusScope.of(this).requestFocus(FocusNode());

  /// Базовый метод для показа SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) =>
      ScaffoldMessenger.of(this).showSnackBar(
        snackBar,
        snackBarAnimationStyle: snackBarAnimationStyle,
      );

  /// Показывает красный SnackBar для ошибок
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(String message) => _showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColor.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

  /// Показывает стандартный SnackBar для уведомлений
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackBar(String message) => _showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

  /// Короткий алиас для ошибок
  void showError(String message) {
    showErrorSnackBar(message);
  }

  /// Короткий алиас для уведомлений
  void showSnack(String message) {
    showSuccessSnackBar(message);
  }

  /// ✅ Алиас для совместимости с вызовом context.showSnackBar()
  void showSnackBar(String message) {
    showSuccessSnackBar(message);
  }

  /// Открыть ссылку
  Future<bool> openLink(String url) async {
    Logger.i('openLink $url');
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      Logger.e('openLink error: $e');
      showError('Не удалось открыть ссылку $url');
      return false;
    }
  }

  /// Открыть телефон
  Future<bool> openTel(String tel) async {
    Logger.i('openTel $tel');
    final uri = Uri.parse('tel:$tel');
    try {
      await launchUrl(uri);
      return true;
    } catch (e) {
      Logger.e('openTel error: $e');
      showError('Не удалось открыть телефон $tel');
      return false;
    }
  }
}
