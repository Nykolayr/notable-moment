import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';
import 'dart:math';

class AnagramEditor extends StatefulWidget {
  final AnagramQuestion initial;
  final void Function(AnagramQuestion data, bool isValid) onChanged;

  const AnagramEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<AnagramEditor> createState() => _AnagramEditorState();
}

class _AnagramEditorState extends State<AnagramEditor> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _hintController;
  late List<String> _letters;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _answerController = TextEditingController(text: widget.initial.answer);
    _hintController = TextEditingController(text: widget.initial.hint);
    _letters =
        widget.initial.letters.isNotEmpty ? List<String>.from(widget.initial.letters) : _shuffle(widget.initial.answer);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    final data = widget.initial.copyWith(
      text: _questionController.text,
      answer: _answerController.text,
      letters: _letters,
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        _answerController.text.trim().length > 1 &&
        !_letters.contains('') &&
        _letters.length == _answerController.text.trim().length;
    widget.onChanged(data, isValid);
  }

  void _onAnswerChanged(String value) {
    setState(() {
      _letters = _shuffle(value);
      _notifyParent();
    });
  }

  List<String> _shuffle(String word) {
    if (word.isEmpty) return [];
    final letters = word.split('');
    letters.shuffle(Random());
    return letters;
  }

  void _reshuffle() {
    setState(() {
      _letters = _shuffle(_answerController.text);
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
            hintText: 'Слово для анаграммы',
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
            spacing: 8,
            runSpacing: 8,
            children: _letters
                .map(
                  (l) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E4EA)),
                    ),
                    child: Text(
                      l.toLowerCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
                    ),
                  ),
                )
                .toList(),
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
