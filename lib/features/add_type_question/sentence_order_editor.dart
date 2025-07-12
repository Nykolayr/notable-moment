import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/sentence_order_question.dart';
import 'package:notable_moments/features/add_type_question/app_input_only_text.dart';
import 'dart:math';

/// SentenceOrderEditor
///
/// Виджет для создания и редактирования вопроса "Приведи в порядок" (слова в предложении).
/// Используется на экране создания/редактирования теста.
/// Принимает и возвращает только SentenceOrderQuestion.

class SentenceOrderEditor extends StatefulWidget {
  final SentenceOrderQuestion initial;
  final void Function(SentenceOrderQuestion data, bool isValid) onChanged;

  const SentenceOrderEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<SentenceOrderEditor> createState() => _SentenceOrderEditorState();
}

class _SentenceOrderEditorState extends State<SentenceOrderEditor> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late List<String> _words;
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _answerController = TextEditingController(text: widget.initial.words.join(' '));
    _words =
        widget.initial.words.isNotEmpty ? List<String>.from(widget.initial.words) : _splitWords(_answerController.text);
    _order = widget.initial.correctOrder.isNotEmpty
        ? List<int>.from(widget.initial.correctOrder)
        : List.generate(_words.length, (i) => i);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final data = widget.initial.copyWith(
      text: _questionController.text,
      words: _words,
      correctOrder: _order,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        _words.length >= 2 &&
        _words.every((w) => w.trim().isNotEmpty) &&
        _order.length == _words.length;
    widget.onChanged(data, isValid);
  }

  List<String> _splitWords(String value) {
    return value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  void _onAnswerChanged(String value) {
    setState(() {
      _words = _splitWords(value);
      _order = List.generate(_words.length, (i) => i);
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
          AppInputOnlyText(
            controller: _answerController,
            hintText: 'Правильный ответ (все слова через пробел)',
            maxLines: 2,
            onChanged: _onAnswerChanged,
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E4EA)),
                ),
                alignment: Alignment.center,
                child: Text(
                  (i < _words.length ? _words[i] : ''),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
