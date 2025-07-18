import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

/// MultipleChoiceEditor
///
/// Виджет для создания и редактирования вопроса с несколькими правильными вариантами ответа (checkbox).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только MultipleChoiceQuestion.
class MultipleChoiceEditor extends StatefulWidget {
  final MultipleChoiceQuestion initial;
  final void Function(MultipleChoiceQuestion data, bool isValid) onChanged;

  const MultipleChoiceEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<MultipleChoiceEditor> createState() => _MultipleChoiceEditorState();
}

class _MultipleChoiceEditorState extends State<MultipleChoiceEditor> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _hintController;
  late List<int> _correctIndexes;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    _optionControllers = widget.initial.options.isNotEmpty
        ? widget.initial.options.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController(), TextEditingController(), TextEditingController()];
    _correctIndexes = List<int>.from(widget.initial.correctIndexes);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
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

  void _notify() {
    final options = _optionControllers.map((c) => c.text.trim()).toList();
    final question = _questionController.text.trim();
    final hint = _hintController.text.trim();
    final isValid = question.isNotEmpty &&
        options.length >= 2 &&
        options.every((o) => o.isNotEmpty) &&
        _correctIndexes.isNotEmpty &&
        _correctIndexes.every((i) => i >= 0 && i < options.length);
    widget.onChanged(
      MultipleChoiceQuestion(
        id: widget.initial.id,
        text: question,
        options: options,
        correctIndexes: _correctIndexes,
        points: widget.initial.points,
        hint: hint,
      ),
      isValid,
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
    _notify();
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index).dispose();
      _correctIndexes.removeWhere((i) => i == index);
      for (int i = 0; i < _correctIndexes.length; i++) {
        if (_correctIndexes[i] > index) {
          _correctIndexes[i]--;
        }
      }
    });
    _notify();
  }

  void _onOptionChanged(int index, String value) {
    _notify();
  }

  void _toggleCorrect(int index, bool? value) {
    setState(() {
      if (value == true) {
        if (!_correctIndexes.contains(index)) {
          _correctIndexes.add(index);
        }
      } else {
        _correctIndexes.removeWhere((i) => i == index);
      }
      _notify();
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
            onChanged: (_) => _notify(),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _optionControllers.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: _correctIndexes.contains(i),
                    onChanged: (v) => _toggleCorrect(i, v),
                  ),
                  Expanded(
                    child: AppInputOnlyText(
                      controller: _optionControllers[i],
                      hintText: 'Вариант №${i + 1}',
                      selected: _correctIndexes.contains(i),
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
          AppInputOnlyText(
            controller: _hintController,
            hintText: 'Текст подсказки',
            maxLines: 3,
            onChanged: (_) => _notify(),
          ),
        ],
      ),
    );
  }
}
