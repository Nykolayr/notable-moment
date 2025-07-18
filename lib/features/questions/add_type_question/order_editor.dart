import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';
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
  late TextEditingController _hintController;
  late List<TextEditingController> _optionControllers;
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
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
    _hintController.dispose();
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
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        items.length >= 2 &&
        items.every((o) => o.trim().isNotEmpty) &&
        _order.length == items.length;
    widget.onChanged(data, isValid);
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _order = List.generate(_optionControllers.length, (i) => i);
    });
    _notifyParent();
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers.removeAt(index).dispose();
      _order = List.generate(_optionControllers.length, (i) => i);
    });
    _notifyParent();
  }

  void _onOptionChanged(int index, String value) {
    _notifyParent();
  }

  void _reshuffle() {
    setState(() {
      _order = List.generate(_optionControllers.length, (i) => i)..shuffle(Random());
      _notifyParent();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Правильный порядок:'),
          const SizedBox(height: 8),
          ...List.generate(
            _order.length,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E4EA)),
              ),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _order[i] < _optionControllers.length ? _optionControllers[_order[i]].text : '',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF222222)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppInputOnlyText(
            controller: _hintController,
            hintText: 'Текст подсказки',
            maxLines: 3,
            onChanged: (_) => setState(_notifyParent),
          ),
        ],
      ),
    );
  }
}
