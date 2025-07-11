enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static WeekDay fromString(String value) {
    return WeekDay.values.firstWhere(
      (day) => day.toString().split('.').last == value.toLowerCase(),
      orElse: () => WeekDay.monday,
    );
  }

  String get shortName => switch (this) {
        WeekDay.monday => 'Пн',
        WeekDay.tuesday => 'Вт',
        WeekDay.wednesday => 'Ср',
        WeekDay.thursday => 'Чт',
        WeekDay.friday => 'Пт',
        WeekDay.saturday => 'Сб',
        WeekDay.sunday => 'Вс',
      };
}
