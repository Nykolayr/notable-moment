import 'package:flutter/material.dart';

class GeneralEditor extends StatelessWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const GeneralEditor({super.key, this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Общий вопрос'));
  }
}
