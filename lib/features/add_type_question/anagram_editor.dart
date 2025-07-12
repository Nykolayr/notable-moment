import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';

class AnagramEditor extends StatelessWidget {
  final AnagramQuestion initial;
  final void Function(AnagramQuestion data, bool isValid) onChanged;

  const AnagramEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Анаграмма'));
  }
}
