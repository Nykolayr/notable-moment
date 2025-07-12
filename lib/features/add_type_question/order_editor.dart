import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';

class OrderEditor extends StatelessWidget {
  final OrderQuestion initial;
  final void Function(OrderQuestion data, bool isValid) onChanged;

  const OrderEditor({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Порядок'));
  }
}
