import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/add_type_question/app_input_only_text.dart';

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
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _optionControllers = widget.initial.options.isNotEmpty
        ? widget.initial.options.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController(), TextEditingController()];
    _correctIndex = widget.initial.correctIndex < _optionControllers.length ? widget.initial.correctIndex : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notify() {
    final options = _optionControllers.map((c) => c.text.trim()).toList();
    final question = _questionController.text.trim();
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
        hint: widget.initial.hint,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Выбери один правильный вариант ответа.',
                style: TextStyle(fontSize: 14, color: Color(0xFF7B7B8B)),
              ),
              const SizedBox(height: 20),
              AppInputOnlyText(
                controller: _questionController,
                hintText: 'Введите текст вопроса',
                onChanged: (_) => _notify(),
              ),
              const SizedBox(height: 24),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: _correctIndex,
                          onChanged: (val) {
                            setState(() {
                              _correctIndex = val!;
                            });
                            _notify();
                          },
                          activeColor: Color(0xFFA3D421),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: AppInputOnlyText(
                            controller: _optionControllers[i],
                            hintText: 'Ответ №${i + 1}',
                            onChanged: (_) => _notify(),
                            selected: _correctIndex == i,
                          ),
                        ),
                        if (_optionControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 22, color: Colors.redAccent),
                            splashRadius: 18,
                            onPressed: () => _removeOption(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF2563EB)),
                    label: const Text('Добавить ответ', style: TextStyle(color: Color(0xFF2563EB))),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
