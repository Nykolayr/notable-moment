import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';

/// SingleChoiceEditor
///
/// Виджет для создания и редактирования вопроса с одним правильным вариантом ответа (radio).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только SingleChoiceQuestion.
class SingleChoiceEditor extends StatefulWidget {
  final SingleChoiceQuestion initial;
  final void Function(SingleChoiceQuestion data, bool isValid) onChanged;

  const SingleChoiceEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<SingleChoiceEditor> createState() => _SingleChoiceEditorState();
}

class _SingleChoiceEditorState extends State<SingleChoiceEditor> {
  late SingleChoiceQuestion data;

  @override
  void initState() {
    super.initState();
    data = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _notify() {
    widget.onChanged(data, true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Один вариант'));
  }
}
