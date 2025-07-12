import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/sentence_order_question.dart';

/// SentenceOrderEditor
///
/// Виджет для создания и редактирования вопроса "Приведи в порядок" (слова в предложении).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только SentenceOrderQuestion.

class SentenceOrderEditor extends StatelessWidget {
  final SentenceOrderQuestion initial;
  final void Function(SentenceOrderQuestion data, bool isValid) onChanged;

  const SentenceOrderEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Приведи в порядок (слова в предложении)'));
  }
}
