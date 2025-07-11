import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay fromTimeString(String timeStr) {
    if (timeStr.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }
}
