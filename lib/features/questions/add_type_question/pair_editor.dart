import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/questions/add_type_question/app_input_only_text.dart';

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
  late List<Pair> _pairs;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initial.text);
    _hintController = TextEditingController(text: widget.initial.hint);
    _pairs = widget.initial.pairs.isNotEmpty
        ? List<Pair>.from(widget.initial.pairs)
        : [
            Pair(left: '', right: ''),
            Pair(left: '', right: ''),
            Pair(left: '', right: ''),
          ];
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
      pairs: _pairs,
      correctPairs: _pairs,
      hint: _hintController.text,
    );
    final isValid = _questionController.text.trim().isNotEmpty &&
        _pairs.length >= 2 &&
        _pairs.every((p) => p.left.trim().isNotEmpty && p.right.trim().isNotEmpty);
    widget.onChanged(data, isValid);
  }

  void _addPair() {
    setState(() {
      _pairs.add(Pair(left: '', right: ''));
    });
    _notifyParent();
  }

  void _removePair(int index) {
    if (_pairs.length <= 2) return;
    setState(() {
      _pairs.removeAt(index);
    });
    _notifyParent();
  }

  void _updatePair(int index, {String? left, String? right}) {
    setState(() {
      _pairs[index] = Pair(
        left: left ?? _pairs[index].left,
        right: right ?? _pairs[index].right,
      );
    });
    _notifyParent();
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
          ...List.generate(
            _pairs.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppInputOnlyText(
                      controller: TextEditingController(text: _pairs[i].left)
                        ..addListener(() {
                          _updatePair(i, left: _pairs[i].left);
                        }),
                      hintText: 'Левая часть ${i + 1}',
                      onChanged: (v) => _updatePair(i, left: v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppInputOnlyText(
                      controller: TextEditingController(text: _pairs[i].right)
                        ..addListener(() {
                          _updatePair(i, right: _pairs[i].right);
                        }),
                      hintText: 'Правая часть ${i + 1}',
                      onChanged: (v) => _updatePair(i, right: v),
                    ),
                  ),
                  if (_pairs.length > 2)
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
