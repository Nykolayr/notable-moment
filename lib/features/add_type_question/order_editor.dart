

import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';

/// OrderEditor
///
/// Виджет для создания и редактирования вопроса "Расставь по порядку" (варианты).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только OrderQuestion.
class OrderEditor extends StatelessWidget {
  final OrderQuestion initial;
  final void Function(OrderQuestion data, bool isValid) onChanged;

  const OrderEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Порядок'));
  }
}
