import 'package:flutter/material.dart';

class AnagramEditor extends StatelessWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const AnagramEditor({super.key, this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Анаграмма'));
  }
}
