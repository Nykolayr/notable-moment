import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'widgets/custom_checkbox.dart';

class MultipleChoiceTestWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final void Function(bool isCorrect, List<int> selected) onAnswered;
  final bool showResult;
  final bool? isCorrect;
  final List<int>? selectedIndexes;
  const MultipleChoiceTestWidget(
      {super.key,
      required this.question,
      required this.onAnswered,
      this.showResult = false,
      this.isCorrect,
      this.selectedIndexes});
  @override
  State<MultipleChoiceTestWidget> createState() => _MultipleChoiceTestWidgetState();
}

class _MultipleChoiceTestWidgetState extends State<MultipleChoiceTestWidget> {
  List<int> selectedIndexesLocal = [];

  @override
  void initState() {
    super.initState();
    selectedIndexesLocal = widget.selectedIndexes ?? [];
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceTestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndexes != oldWidget.selectedIndexes) {
      selectedIndexesLocal = widget.selectedIndexes ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResult = widget.showResult;
    final isCorrect = widget.isCorrect;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          widget.question.options.length,
          (index) => _buildOptionItem(index, showResult, isCorrect),
        ),
        const SizedBox(height: 20),
        if (showResult && isCorrect != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFE6F9E2) : const Color(0xFFFFE6E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isCorrect ? 'Верно!' : 'Неверно! -1 ⚡',
                style: TextStyle(
                  color: isCorrect ? const Color(0xFF4CD964) : const Color(0xFFFF3B30),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionItem(int index, bool showResult, bool? isCorrect) {
    final isSelected = (widget.selectedIndexes ?? selectedIndexesLocal).contains(index);
    final isRight = showResult && widget.question.correctIndexes.contains(index);
    final isWrong = showResult && isSelected && !isRight;
    Color borderColor = const Color(0xFFE0E0E0);
    Color? fillColor;
    if (isRight) {
      borderColor = const Color(0xFF4CD964);
      fillColor = const Color(0xFFE6F9E2);
    } else if (isWrong) {
      borderColor = const Color(0xFFFF3B30);
      fillColor = const Color(0xFFFFE6E6);
    } else if (isSelected && !showResult) {
      borderColor = const Color(0xFFFFD600);
      fillColor = const Color(0xFFFFF9E2);
    }
    return GestureDetector(
      onTap: showResult
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  selectedIndexesLocal.remove(index);
                } else {
                  selectedIndexesLocal.add(index);
                }
              });
              widget.onAnswered(false, selectedIndexesLocal);
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fillColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            CustomCheckbox(
              selected: isSelected,
              showResult: showResult,
              isRight: isRight,
              isWrong: isWrong,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isWrong
                      ? const Color(0xFFFF3B30)
                      : isRight
                          ? const Color(0xFF4CD964)
                          : const Color(0xFF222222),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
