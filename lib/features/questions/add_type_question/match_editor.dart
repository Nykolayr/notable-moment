import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';
import 'dart:math';

/// Редактор для создания и редактирования вопроса с сопоставлением
class MatchEditor extends StatefulWidget {
  final PairQuestion initial;
  final void Function(PairQuestion data, bool isValid) onChanged;

  const MatchEditor({super.key, required this.initial, required this.onChanged});

  @override
  State<MatchEditor> createState() => _MatchEditorState();
}

class _MatchEditorState extends State<MatchEditor> {
  late TextEditingController _questionController;
  late TextEditingController _hintController;
  late List<TextEditingController> _leftControllers;
  late List<TextEditingController> _rightControllers;
  late List<String> _leftShuffled;
  late List<String> _rightShuffled;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    final pairs = widget.initial.pairs.isNotEmpty ? widget.initial.pairs : [Pair(left: '', right: '')];
    _leftControllers = pairs.map((e) => TextEditingController(text: e.left)).toList();
    _rightControllers = pairs.map((e) => TextEditingController(text: e.right)).toList();
    _leftShuffled = _leftControllers.map((c) => c.text).toList();
    _rightShuffled = _rightControllers.map((c) => c.text).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _hintController.dispose();
    for (final c in _leftControllers) {
      c.dispose();
    }
    for (final c in _rightControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    final pairs = List.generate(
      _leftControllers.length,
      (i) => Pair(left: _leftControllers[i].text, right: _rightControllers[i].text),
    );
    final data = widget.initial.copyWith(
      text: _questionController.text,
      pairs: pairs,
      correctPairs: pairs,
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        pairs.isNotEmpty &&
        pairs.every((p) => p.left.trim().isNotEmpty && p.right.trim().isNotEmpty);
    widget.onChanged(data, isValid);
  }

  void _addPair() {
    setState(() {
      _leftControllers.add(TextEditingController());
      _rightControllers.add(TextEditingController());
      _leftShuffled = _leftControllers.map((c) => c.text).toList();
      _rightShuffled = _rightControllers.map((c) => c.text).toList();
      _notifyParent();
    });
  }

  void _removePair(int idx) {
    if (_leftControllers.length <= 1) return;
    setState(() {
      _leftControllers.removeAt(idx).dispose();
      _rightControllers.removeAt(idx).dispose();
      _leftShuffled = _leftControllers.map((c) => c.text).toList();
      _rightShuffled = _rightControllers.map((c) => c.text).toList();
      _notifyParent();
    });
  }

  void _reshuffle() {
    setState(() {
      _leftShuffled = List<String>.from(_leftControllers.map((c) => c.text));
      _rightShuffled = List<String>.from(_rightControllers.map((c) => c.text));
      _leftShuffled.shuffle(Random());
      _rightShuffled.shuffle(Random());
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
          Row(
            children: [
              const Expanded(child: Text('Левая колонка', textAlign: TextAlign.center)),
              const SizedBox(width: 8),
              const Expanded(child: Text('Правая колонка', textAlign: TextAlign.center)),
            ],
          ),
          ...List.generate(
            _leftControllers.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppInputOnlyText(
                      controller: _leftControllers[i],
                      hintText: 'Левый элемент',
                      onChanged: (_) => setState(_notifyParent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppInputOnlyText(
                      controller: _rightControllers[i],
                      hintText: 'Правый элемент',
                      onChanged: (_) => setState(_notifyParent),
                    ),
                  ),
                  if (_leftControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 22, color: Colors.redAccent),
                      onPressed: () => _removePair(i),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addPair,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Добавить пару'),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(
                    _leftShuffled.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E4EA)),
                      ),
                      alignment: Alignment.center,
                      child: Text(_leftShuffled[i], style: const TextStyle(fontSize: 16, color: Color(0xFF222222))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: List.generate(
                    _rightShuffled.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E4EA)),
                      ),
                      alignment: Alignment.center,
                      child: Text(_rightShuffled[i], style: const TextStyle(fontSize: 16, color: Color(0xFF222222))),
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
