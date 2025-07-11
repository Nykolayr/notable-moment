import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/time_of_day_extension.dart';
import 'package:notable_moments/features/routes/enum/week_day_enum.dart';

class WorkingPeriod {
  final List<WeekDay> days;
  final TimeOfDay timeFrom;
  final TimeOfDay timeTo;
  final bool isAllDay;
  final bool isClosed;

  List<WeekDay> get sortedDays => List.from(days)..sort((a, b) => a.index.compareTo(b.index));

  bool get hasError {
    if (days.isEmpty) return true;
    if (!isAllDay && !isClosed) {
      final fromMinutes = timeFrom.hour * 60 + timeFrom.minute;
      final toMinutes = timeTo.hour * 60 + timeTo.minute;
      if (fromMinutes >= toMinutes) return true;
    }
    return false;
  }

  const WorkingPeriod({
    required this.days,
    required this.timeFrom,
    required this.timeTo,
    this.isAllDay = false,
    this.isClosed = false,
  });

  factory WorkingPeriod.fromMap(Map<String, dynamic> map) => WorkingPeriod(
        days: (map['days'] as List<dynamic>).map((day) => WeekDay.fromString(day as String)).toList(),
        timeFrom: TimeOfDayExtension.fromTimeString(map['timeFrom'] as String? ?? ''),
        timeTo: TimeOfDayExtension.fromTimeString(map['timeTo'] as String? ?? ''),
        isAllDay: map['isAllDay'] as bool? ?? false,
        isClosed: map['isClosed'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'days': days.map((day) => day.toString().split('.').last).toList(),
        'timeFrom': timeFrom.toTimeString(),
        'timeTo': timeTo.toTimeString(),
        'isAllDay': isAllDay,
        'isClosed': isClosed,
      };

  // copyWith
  WorkingPeriod copyWith({
    List<WeekDay>? days,
    TimeOfDay? timeFrom,
    TimeOfDay? timeTo,
    bool? isAllDay,
    bool? isClosed,
  }) =>
      WorkingPeriod(
        days: days ?? this.days,
        timeFrom: timeFrom ?? this.timeFrom,
        timeTo: timeTo ?? this.timeTo,
        isAllDay: isAllDay ?? this.isAllDay,
        isClosed: isClosed ?? this.isClosed,
      );

  String get daysText {
    if (days.isEmpty) return '';

    if (days.length == WeekDay.values.length) {
      return 'Пн-Вс';
    }

    if (days.length == 1) {
      return days.first.shortName;
    }

    // Сортируем дни по их индексу
    final sortedDays = List<WeekDay>.from(days)..sort((a, b) => a.index.compareTo(b.index));

    for (int i = 0; i < sortedDays.length; i++) {
      // добавь элементы с i и потом добавь отсавшиеся элементы
      final newDays = [
        ...sortedDays.sublist(i, sortedDays.length),
        ...sortedDays.sublist(0, i),
      ];

      final isSequential = isDaysSequential(newDays);
      if (isSequential) {
        return '${newDays.first.shortName}-${newDays.last.shortName}';
      }
    }

    return sortedDays.map((day) => day.shortName).join(', ');
  }

  bool isDaysSequential(List<WeekDay> days) {
    if (days.isEmpty || days.length == 1) return true;

    // проверяем последовательность в прямом направлении с учётом переполнения
    for (int i = 1; i < days.length; i++) {
      int expectedIndex = (days[0].index + i) % WeekDay.values.length;
      if (days[i].index != expectedIndex) return false;
    }
    return true;
  }

  String get timeText {
    if (isClosed) return 'Выходной';
    if (isAllDay) return 'Круглосуточно';

    final fromStr = '${timeFrom.hour.toString().padLeft(2, '0')}:${timeFrom.minute.toString().padLeft(2, '0')}';
    final toStr = '${timeTo.hour.toString().padLeft(2, '0')}:${timeTo.minute.toString().padLeft(2, '0')}';
    return '$fromStr-$toStr';
  }

  @override
  String toString() {
    if (days.isEmpty) return '';
    return '$daysText: $timeText';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingPeriod &&
          const ListEquality<WeekDay>().equals(days, other.days) &&
          timeFrom == other.timeFrom &&
          timeTo == other.timeTo &&
          isAllDay == other.isAllDay &&
          isClosed == other.isClosed;

  @override
  int get hashCode => days.hashCode ^ timeFrom.hashCode ^ timeTo.hashCode ^ isAllDay.hashCode ^ isClosed.hashCode;
}

class WorkingHours {
  final List<WorkingPeriod> periods;

  bool get hasError {
    if (periods.isEmpty) return false;

    // Check individual periods for errors
    for (final period in periods) {
      if (period.hasError) return true;
    }

    // // Check for day intersections between periods
    // for (int i = 0; i < periods.length; i++) {
    //   for (int j = i + 1; j < periods.length; j++) {
    //     for (final day in periods[i].days) {
    //       if (periods[j].days.contains(day)) {
    //         return true;
    //       }
    //     }
    //   }
    // }

    return false;
  }

  const WorkingHours({required this.periods});

  factory WorkingHours.fromMap(Map<String, dynamic> map) => WorkingHours(
        periods: (map['periods'] as List<dynamic>? ?? [])
            .map((period) => WorkingPeriod.fromMap(period as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'periods': periods.map((period) => period.toMap()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingHours && const ListEquality<WorkingPeriod>().equals(periods, other.periods);

  @override
  int get hashCode => periods.hashCode;

  @override
  String toString() => 'WorkingHours($periods)';
}
