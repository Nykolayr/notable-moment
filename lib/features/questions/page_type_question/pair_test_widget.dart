import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';

class PairTestWidget extends StatefulWidget {
  final PairQuestion question;
  final void Function(List<int> selectedIndexes, bool canAnswer)? onSelectionChanged;
  final void Function(bool isCorrect, List<int> selectedIndexes)? onPairChecked;
  final VoidCallback? onAllPairsCompleted;
  final ValueNotifier<bool>? checkPairSignal;

  const PairTestWidget({
    super.key,
    required this.question,
    this.onSelectionChanged,
    this.onPairChecked,
    this.onAllPairsCompleted,
    this.checkPairSignal,
  });

  @override
  State<PairTestWidget> createState() => _PairTestWidgetState();
}

class _PairTestWidgetState extends State<PairTestWidget> {
  int? selectedLeftIndex;
  int? selectedRightIndex;
  Set<int> lockedLeftIndexes = {};
  Set<int> lockedRightIndexes = {};
  Set<int> wrongLeftIndexes = {};
  Set<int> wrongRightIndexes = {};
  bool allPairsCompleted = false;
  bool? lastPairCorrect;

  @override
  void initState() {
    super.initState();
    widget.checkPairSignal?.addListener(_onCheckPairSignal);
  }

  @override
  void dispose() {
    widget.checkPairSignal?.removeListener(_onCheckPairSignal);
    super.dispose();
  }

  void _onCheckPairSignal() {
    if (widget.checkPairSignal?.value == true) {
      _checkPair();
      widget.checkPairSignal?.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.question.pairs;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Надпись типа теста
          Text(
            QuestionTypeTest.pair.title,
            style: const TextStyle(color: Color(0xFFB0B4BB), fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          // Вопрос
          Text(widget.question.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Row(
            children: [
              // Левая колонка
              Expanded(
                child: Column(
                  children: List.generate(pairs.length, (index) {
                    final isLocked = lockedLeftIndexes.contains(index);
                    final isWrong = wrongLeftIndexes.contains(index);
                    final isSelected = selectedLeftIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: isLocked
                            ? null
                            : () {
                                setState(() {
                                  selectedLeftIndex = index;
                                  selectedRightIndex = null;
                                  wrongLeftIndexes.clear();
                                  wrongRightIndexes.clear();
                                });
                                final canAnswer = _canAnswer();
                                widget.onSelectionChanged?.call(
                                  selectedRightIndex != null
                                      ? [selectedLeftIndex!, selectedRightIndex!]
                                      : [selectedLeftIndex!],
                                  canAnswer,
                                );
                              },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLocked
                                ? const Color(0xFFEFFFC3)
                                : isWrong
                                    ? const Color(0xFFFFE6E6)
                                    : isSelected
                                        ? const Color(0xFF9E9E9E)
                                        : const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLocked
                                  ? const Color(0xFF97CB06)
                                  : isWrong
                                      ? const Color(0xFFFF3B30)
                                      : isSelected
                                          ? const Color(0xFF757575)
                                          : Colors.transparent,
                              width: isLocked || isWrong || isSelected ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            pairs[index].left,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected || isLocked ? FontWeight.w500 : FontWeight.w400,
                              color: isWrong
                                  ? const Color(0xFFFF3B30)
                                  : isLocked
                                      ? const Color(0xFF97CB06)
                                      : isSelected
                                          ? Colors.white
                                          : const Color(0xFF222222),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              // Правая колонка
              Expanded(
                child: Column(
                  children: List.generate(pairs.length, (index) {
                    final isLocked = lockedRightIndexes.contains(index);
                    final isWrong = wrongRightIndexes.contains(index);
                    final isSelected = selectedRightIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: isLocked
                            ? null
                            : () {
                                setState(() {
                                  selectedRightIndex = index;
                                  wrongLeftIndexes.clear();
                                  wrongRightIndexes.clear();
                                });
                                final canAnswer = _canAnswer();
                                widget.onSelectionChanged?.call(
                                  selectedLeftIndex != null
                                      ? [selectedLeftIndex!, selectedRightIndex!]
                                      : [selectedRightIndex!],
                                  canAnswer,
                                );
                              },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isLocked
                                ? const Color(0xFFEFFFC3)
                                : isWrong
                                    ? const Color(0xFFFFE6E6)
                                    : isSelected
                                        ? const Color(0xFF9E9E9E)
                                        : const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLocked
                                  ? const Color(0xFF97CB06)
                                  : isWrong
                                      ? const Color(0xFFFF3B30)
                                      : isSelected
                                          ? const Color(0xFF757575)
                                          : Colors.transparent,
                              width: isLocked || isWrong || isSelected ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            pairs[index].right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected || isLocked ? FontWeight.w500 : FontWeight.w400,
                              color: isWrong
                                  ? const Color(0xFFFF3B30)
                                  : isLocked
                                      ? const Color(0xFF97CB06)
                                      : isSelected
                                          ? Colors.white
                                          : const Color(0xFF222222),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _checkPair() {
    if (selectedLeftIndex == null || selectedRightIndex == null) return;
    final leftIdx = selectedLeftIndex!;
    final rightIdx = selectedRightIndex!;
    final left = widget.question.pairs[leftIdx].left;
    final right = widget.question.pairs[rightIdx].right;
    final isCorrect = widget.question.correctPairs.any((pair) => pair.left == left && pair.right == right);
    setState(() {
      if (isCorrect) {
        lockedLeftIndexes.add(leftIdx);
        lockedRightIndexes.add(rightIdx);
        selectedLeftIndex = null;
        selectedRightIndex = null;
        lastPairCorrect = true;
      } else {
        wrongLeftIndexes.add(leftIdx);
        wrongRightIndexes.add(rightIdx);
        lastPairCorrect = false;
      }
    });
    widget.onPairChecked?.call(isCorrect, [leftIdx, rightIdx]);
    if (_allPairsFound()) {
      allPairsCompleted = true;
      widget.onAllPairsCompleted?.call();
    }
  }

  bool _canAnswer() {
    return selectedLeftIndex != null &&
        selectedRightIndex != null &&
        !lockedLeftIndexes.contains(selectedLeftIndex) &&
        !lockedRightIndexes.contains(selectedRightIndex);
  }

  bool _allPairsFound() {
    return lockedLeftIndexes.length == widget.question.correctPairs.length;
  }
}
