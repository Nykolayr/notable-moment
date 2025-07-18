import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

/// TrueFalseEditor
///
/// Виджет для создания и редактирования вопроса "Правда/Ложь".
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только TrueFalseQuestion.

class TrueFalseEditor extends StatefulWidget {
  final TrueFalseQuestion initial;
  final void Function(TrueFalseQuestion data, bool isValid) onChanged;

  const TrueFalseEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<TrueFalseEditor> createState() => _TrueFalseEditorState();
}

class _TrueFalseEditorState extends State<TrueFalseEditor> {
  late TextEditingController _questionController;
  late TextEditingController _hintController;
  late bool _correct;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    _correct = widget.initial.correct;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final data = widget.initial.copyWith(
      text: _questionController.text,
      correct: _correct,
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty;
    widget.onChanged(data, isValid);
  }

  void _onSelect(bool value) {
    setState(() {
      _correct = value;
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
          const Text('Выберите правильный ответ:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onSelect(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _correct ? const Color(0xFFF1FFCC) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _correct ? const Color(0xFFA3D421) : const Color(0xFFE0E4EA),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Правда',
                      style: TextStyle(
                        fontWeight: _correct ? FontWeight.bold : FontWeight.normal,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _onSelect(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_correct ? const Color(0xFFF1FFCC) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_correct ? const Color(0xFFA3D421) : const Color(0xFFE0E4EA),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Ложь',
                      style: TextStyle(
                        fontWeight: !_correct ? FontWeight.bold : FontWeight.normal,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
