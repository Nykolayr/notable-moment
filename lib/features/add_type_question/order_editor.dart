import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';
import 'package:notable_moments/features/add_type_question/app_input_only_text.dart';
import 'dart:math';

class OrderEditor extends StatefulWidget {
  final OrderQuestion initial;
  final void Function(OrderQuestion data, bool isValid) onChanged;

  const OrderEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<OrderEditor> createState() => _OrderEditorState();
}

class _OrderEditorState extends State<OrderEditor> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _optionControllers = widget.initial.items.isNotEmpty
        ? widget.initial.items.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController(), TextEditingController(), TextEditingController()];
    _order = widget.initial.correctOrder.isNotEmpty
        ? List<int>.from(widget.initial.correctOrder)
        : List.generate(_optionControllers.length, (i) => i);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    final items = _optionControllers.map((c) => c.text).toList();
    final data = widget.initial.copyWith(
      text: _questionController.text,
      items: items,
      correctOrder: _order,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        items.length >= 2 &&
        items.every((o) => o.trim().isNotEmpty) &&
        _order.length == items.length;
    widget.onChanged(data, isValid);
  }

  void _onOptionChanged(int idx, String value) {
    setState(_notifyParent);
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _order.add(_order.length);
      _notifyParent();
    });
  }

  void _removeOption(int idx) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers.removeAt(idx).dispose();
      _order.removeWhere((i) => i == idx);
      _order = _order.map((i) => i > idx ? i - 1 : i).toList();
      _notifyParent();
    });
  }

  void _reshuffle() {
    setState(() {
      _order.shuffle(Random());
      _notifyParent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _optionControllers.map((c) => c.text).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInputOnlyText(
            controller: _questionController,
            hintText: 'Текст вопроса',
            onChanged: (_) => setState(_notifyParent),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _optionControllers.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppInputOnlyText(
                      controller: _optionControllers[i],
                      hintText: 'Вариант №${i + 1}',
                      onChanged: (v) => _onOptionChanged(i, v),
                    ),
                  ),
                  if (_optionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 22, color: Colors.redAccent),
                      onPressed: () => _removeOption(i),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Добавить вариант'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: _reshuffle,
                icon: const Icon(Icons.shuffle, size: 20),
                label: const Text('Перемешать'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_order.length, (idx) {
              final i = _order[idx];
              return Container(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E4EA)),
                ),
                alignment: Alignment.center,
                child: Text(
                  (i < items.length ? items[i] : ''),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _order.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 16, color: Color(0xFFB0B0B8))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
