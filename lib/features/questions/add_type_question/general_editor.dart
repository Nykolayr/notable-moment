import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

class GeneralEditor extends StatefulWidget {
  final GeneralQuestion initial;
  final void Function(GeneralQuestion data, bool isValid) onChanged;

  const GeneralEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<GeneralEditor> createState() => _GeneralEditorState();
}

class _GeneralEditorState extends State<GeneralEditor> {
  late TextEditingController _questionController;
  late int _correctIndex;
  final List<String> _options = const ['Да', 'Нет'];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _correctIndex = widget.initial.correctIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final data = widget.initial.copyWith(
      text: _questionController.text,
      options: _options,
      correctIndex: _correctIndex,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_options.length, (i) {
              final selected = _correctIndex == i;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => _onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFF1FFCC) : const Color(0xFFF7F8FA),
                        border: Border.all(
                          color: selected ? const Color(0xFFA3D421) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _options[i],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: selected ? const Color(0xFF222222) : const Color(0xFFB0B0B8),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
