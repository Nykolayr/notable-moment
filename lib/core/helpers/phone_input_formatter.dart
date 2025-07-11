import 'dart:math';

import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Удаляем все нецифровые символы
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Ограничиваем длину до 11 цифр
    final truncated = digitsOnly.length > 11 ? digitsOnly.substring(0, 11) : digitsOnly;

    var result = '';
    if (truncated.isNotEmpty) {
      // Добавляем +7
      result = '+7';
      if (truncated.length > 1) {
        // Добавляем код города
        result += ' (${truncated.substring(1, min(4, truncated.length))})';
      }
      if (truncated.length > 4) {
        // Добавляем первые три цифры номера
        result += ' ${truncated.substring(4, min(7, truncated.length))}';
      }
      if (truncated.length > 7) {
        // Добавляем следующие две цифры
        result += '-${truncated.substring(7, min(9, truncated.length))}';
      }
      if (truncated.length > 9) {
        // Добавляем последние две цифры
        result += '-${truncated.substring(9, 11)}';
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
