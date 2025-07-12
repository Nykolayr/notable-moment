import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';

class MultipleChoiceEditor extends StatelessWidget {
  final MultipleChoiceQuestion initial;
  final void Function(MultipleChoiceQuestion data, bool isValid) onChanged;

  const MultipleChoiceEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Несколько вариантов'));
  }
}
