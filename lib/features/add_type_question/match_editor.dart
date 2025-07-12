import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';

class MatchEditor extends StatelessWidget {
  final PairQuestion initial;
  final void Function(PairQuestion data, bool isValid) onChanged;

  const MatchEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Соответствие'));
  }
}
