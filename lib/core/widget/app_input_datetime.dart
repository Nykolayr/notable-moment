import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notable_moments/core/widget/app_input.dart';

class AppInputDateTime extends StatefulWidget {
  const AppInputDateTime({
    super.key,
    required this.controller,
    this.label,
    this.hintText = 'дд.мм.гггг',
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final TextEditingController controller;
  final String? label;
  final String hintText;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  @override
  State<AppInputDateTime> createState() => _AppInputDateTimeState();
}

class _AppInputDateTimeState extends State<AppInputDateTime> {
  final _dateFormat = DateFormat('dd.MM.yyyy');

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final initialDate = _tryParseDate(widget.controller.text) ?? now;
    final pickedDate = await showDatePicker(
      locale: const Locale('ru'),
      context: context,
      initialDate: initialDate.isBefore(now) ? initialDate : now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      widget.controller.text = _dateFormat.format(pickedDate);
    }
  }

  DateTime? _tryParseDate(String value) {
    try {
      return _dateFormat.parse(value);
    } catch (_) {
      return null;
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите дату';
    }

    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      keyboardType: TextInputType.datetime,
      autovalidateMode: widget.autovalidateMode,
      validator: _validateDate,
      onTap: _showDatePicker,
      readOnly: true,
    );
  }
}
