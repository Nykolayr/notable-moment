import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/add_type_question/app_input_only_text.dart';
import 'package:notable_moments/core/theme/app_color.dart';

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
  late List<int> _correctIndexes;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _optionControllers = widget.initial.options.map((e) => TextEditingController(text: e)).toList();
    if (_optionControllers.length < 2) {
      // Гарантируем минимум два варианта
      while (_optionControllers.length < 2) {
        _optionControllers.add(TextEditingController());
      }
    }
    _correctIndexes = List<int>.from(widget.initial.correctIndexes);
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
    final options = _optionControllers.map((c) => c.text).toList();
    final data = widget.initial.copyWith(
      text: _questionController.text,
      options: options,
      correctIndexes: _correctIndexes,
    );
    final isValid = _validate(data);
    widget.onChanged(data, isValid);
  }

  bool _validate(MultipleChoiceQuestion data) {
    if (data.text.trim().isEmpty) return false;
    if (data.options.length < 2) return false;
    if (data.options.any((o) => o.trim().isEmpty)) return false;
    if (data.correctIndexes.isEmpty) return false;
    if (data.correctIndexes.any((i) => i < 0 || i >= data.options.length)) return false;
    return true;
  }

  void _onOptionChanged(int idx, String value) {
    setState(() {
      _notifyParent();
    });
  }

  void _onCorrectChanged(int idx, bool? value) {
    setState(() {
      if (value == true) {
        if (!_correctIndexes.contains(idx)) _correctIndexes.add(idx);
      } else {
        _correctIndexes.remove(idx);
      }
      _notifyParent();
    });
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _notifyParent();
    });
  }

  void _removeOption(int idx) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers.removeAt(idx).dispose();
      _correctIndexes.removeWhere((i) => i == idx);
      _correctIndexes = _correctIndexes.map((i) => i > idx ? i - 1 : i).toList();
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
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Выберите несколько правильных ответов.',
              style: TextStyle(fontSize: 15, color: Color(0xFF222222)),
            ),
          ),
          AppInputOnlyText(
            controller: _questionController,
            hintText: 'Текст вопроса',
            onChanged: (_) => setState(_notifyParent),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _optionControllers.length,
            (i) {
              final selected = _correctIndexes.contains(i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFF1FFCC) : const Color(0xFFF7F8FA),
                    border: Border.all(
                      color: selected ? const Color(0xFFA3D421) : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _CustomCheckbox(
                          value: selected,
                          onTap: () => _onCorrectChanged(i, !selected),
                        ),
                      ),
                      Expanded(
                        child: AppInputOnlyText(
                          controller: _optionControllers[i],
                          hintText: 'Ответ № ${i + 1}',
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
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Добавить вариант'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const _CustomCheckbox({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: value ? const Color(0xFFF1FFCC) : Colors.white,
          border: Border.all(
            color: value ? Color(0xFFA3D421) : AppColor.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: value ? Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }
}
