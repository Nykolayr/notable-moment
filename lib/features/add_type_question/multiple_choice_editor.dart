import 'package:flutter/material.dart';

class MultipleChoiceEditor extends StatelessWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const MultipleChoiceEditor({super.key, this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Несколько вариантов'));
  }
}
