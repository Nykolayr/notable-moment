import 'package:flutter/material.dart';

class OrderEditor extends StatelessWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const OrderEditor({super.key, this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Порядок'));
  }
}
