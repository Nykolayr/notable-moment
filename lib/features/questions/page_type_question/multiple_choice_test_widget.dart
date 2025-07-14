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
  final List<int>? wrongIndexes;
  const MultipleChoiceTestWidget(
      {super.key,
      required this.question,
      required this.onAnswered,
      this.showResult = false,
      this.isCorrect,
      this.selectedIndexes,
      this.wrongIndexes});
  @override
  State<MultipleChoiceTestWidget> createState() => _MultipleChoiceTestWidgetState();
}

class _MultipleChoiceTestWidgetState extends State<MultipleChoiceTestWidget> {
  // Убираю локальное состояние выбора

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
        // Удаляю чип 'Неверно!' из блока
        // if (showResult && isCorrect == false)
        //   Align(
        //     alignment: Alignment.centerLeft,
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: const Color(0xFFFFE6E6),
        //         borderRadius: BorderRadius.circular(16),
        //       ),
        //       child: const Text(
        //         'Неверно! -1 ⚡',
        //         style: TextStyle(
        //           color: Color(0xFFFF3B30),
        //           fontWeight: FontWeight.bold,
        //           fontSize: 16,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildOptionItem(int index, bool showResult, bool? isCorrect) {
    final isSelected = (widget.selectedIndexes ?? []).contains(index);
    final isWrong =
        (showResult && isSelected && isCorrect == false && !widget.question.correctIndexes.contains(index)) ||
            (widget.wrongIndexes != null &&
                widget.wrongIndexes!.contains(index) &&
                !widget.question.correctIndexes.contains(index));
    Color borderColor = const Color(0xFFE0E0E0);
    Color? fillColor;
    if (isWrong) {
      borderColor = const Color(0xFFFF3B30);
      fillColor = const Color(0xFFFFE6E6);
    } else if (isSelected && !showResult) {
      borderColor = const Color(0xFF97CB06);
      fillColor = const Color(0xFFEFFFC3);
    }
    return GestureDetector(
      onTap: showResult
          ? null
          : () {
              // Только через внешний selectedIndexes
              final newList = List<int>.from(widget.selectedIndexes ?? []);
              if (isSelected) {
                newList.remove(index);
              } else {
                newList.add(index);
              }
              widget.onAnswered(false, newList);
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
              isRight: false, // Always false for incorrect options
              isWrong: isWrong,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isWrong ? const Color(0xFFFF3B30) : const Color(0xFF222222),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
