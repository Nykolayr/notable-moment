import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';

/// Виджет для создания и редактирования общего вопроса (например, Да/Нет).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только GeneralQuestion.
class GeneralEditor extends StatelessWidget {
  final GeneralQuestion initial;
  final void Function(GeneralQuestion data, bool isValid) onChanged;

  const GeneralEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Общий вопрос (Да/Нет)'));
  }
}
