abstract class Validator {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите почту';
    }
    final emailRegex = RegExp(r'^[\w-\.+]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Недопустимый формат почты';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 8) {
      return 'Пароль должен содержать не менее 8 символов';
    }
    return null;
  }

  //confirm password
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value != password) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    return null;
  }

  static String? birthday(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите дату рождения';
    }

    // Проверяем формат дд.мм.гггг
    if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
      return 'Введите корректную дату в формате дд.мм.гггг';
    }

    // Проверяем что дата корректная
    try {
      final parts = value.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      // Проверяем что дата не в будущем
      if (date.isAfter(DateTime.now())) {
        return 'Дата рождения не может быть в будущем';
      }

      // Проверяем что дата не слишком старая (больше 150 лет)
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 365 * 150)))) {
        return 'Дата рождения не может быть раньше 1874 года';
      }
    } catch (e) {
      return 'Введите корректную дату в формате дд.мм.гггг';
    }

    return null;
  }

  static String? phoneMasked(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }
    final phoneRegex = RegExp(r'\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}');
    if (!phoneRegex.hasMatch(value)) {
      return 'Неверный формат номера';
    }
    return null;
  }

  // url
  static String? url(String? value) {
    if (value == null) {
      return 'Введите ссылку';
    }
    final urlRegex = RegExp(r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Недопустимый формат ссылки';
    }

    return null;
  }

  // phone russian
  static String? phone(String? value) {
    if (value == null) {
      return 'Введите номер телефона';
    }
    // +7 or 8
    final phoneRegex = RegExp(r'^\+?7?\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Недопустимый формат номера телефона';
    }
    return null;
  }
}
