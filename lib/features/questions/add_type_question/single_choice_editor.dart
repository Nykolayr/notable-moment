import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

/// Виджет для создания и редактирования вопроса с одним правильным вариантом ответа (radio).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только SingleChoiceQuestion.

class SingleChoiceEditor extends StatefulWidget {
  final SingleChoiceQuestion initial;
  final void Function(SingleChoiceQuestion data, bool isValid) onChanged;

  const SingleChoiceEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<SingleChoiceEditor> createState() => _SingleChoiceEditorState();
}

class _SingleChoiceEditorState extends State<SingleChoiceEditor> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _hintController;
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    _optionControllers = widget.initial.options.isNotEmpty
        ? widget.initial.options.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController(), TextEditingController(), TextEditingController()];
    _correctIndex = widget.initial.correctIndex;
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
        _correctIndex >= 0 &&
        _correctIndex < options.length;
    widget.onChanged(
      SingleChoiceQuestion(
        id: widget.initial.id,
        text: question,
        options: options,
        correctIndex: _correctIndex,
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
      if (_correctIndex == index) {
        _correctIndex = 0;
      } else if (_correctIndex > index) {
        _correctIndex--;
      }
    });
    _notify();
  }

  void _onOptionChanged(int index, String value) {
    _notify();
  }

  void _onSelectCorrect(int index) {
    setState(() {
      _correctIndex = index;
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
                  Radio<int>(
                    value: i,
                    groupValue: _correctIndex,
                    onChanged: (v) => _onSelectCorrect(v!),
                  ),
                  Expanded(
                    child: AppInputOnlyText(
                      controller: _optionControllers[i],
                      hintText: 'Вариант №${i + 1}',
                      selected: _correctIndex == i,
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
