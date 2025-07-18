import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

/// GeneralEditor
///
/// Виджет для создания и редактирования вопроса "Общий".
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только GeneralQuestion.

class GeneralEditor extends StatefulWidget {
  final GeneralQuestion initial;
  final void Function(GeneralQuestion data, bool isValid) onChanged;

  const GeneralEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<GeneralEditor> createState() => _GeneralEditorState();
}

class _GeneralEditorState extends State<GeneralEditor> {
  late TextEditingController _questionController;
  late TextEditingController _hintController;
  late int _correctIndex;
  final List<String> _options = const ['Да', 'Нет'];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    _correctIndex = widget.initial.correctIndex;
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
      options: _options,
      correctIndex: _correctIndex,
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty && _correctIndex >= 0 && _correctIndex < _options.length;
    widget.onChanged(data, isValid);
  }

  void _onSelect(int idx) {
    setState(() {
      _correctIndex = idx;
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
              for (int i = 0; i < _options.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _correctIndex == i ? const Color(0xFFF1FFCC) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _correctIndex == i ? const Color(0xFFA3D421) : const Color(0xFFE0E4EA),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _options[i],
                        style: TextStyle(
                          fontWeight: _correctIndex == i ? FontWeight.bold : FontWeight.normal,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
