import 'package:flutter/material.dart';

class TrueFalseEditor extends StatelessWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const TrueFalseEditor({super.key, this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Правда/Ложь'));
  }
}
