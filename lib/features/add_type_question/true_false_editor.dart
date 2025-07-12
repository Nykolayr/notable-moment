import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';

/// TrueFalseEditor
///
/// Виджет для создания и редактирования вопроса "Правда/Ложь".
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только TrueFalseQuestion.
class TrueFalseEditor extends StatelessWidget {
  final TrueFalseQuestion initial;
  final void Function(TrueFalseQuestion data, bool isValid) onChanged;

  const TrueFalseEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Правда/Ложь'));
  }
}
