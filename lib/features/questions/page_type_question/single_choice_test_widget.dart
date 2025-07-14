import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'widgets/custom_radio.dart';

class SingleChoiceTestWidget extends StatefulWidget {
  final SingleChoiceQuestion question;
  final void Function(bool isCorrect, List<int> selected) onAnswered;
  final List<int> selectedIndexes;
  final bool showResult;
  final bool? isCorrect;
  final List<int>? wrongIndexes;
  const SingleChoiceTestWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    required this.selectedIndexes,
    this.showResult = false,
    this.isCorrect,
    this.wrongIndexes,
  });

  @override
  State<SingleChoiceTestWidget> createState() => _SingleChoiceTestWidgetState();
}

class _SingleChoiceTestWidgetState extends State<SingleChoiceTestWidget> {
  // Убираю локальное состояние выбора

  @override
  Widget build(BuildContext context) {
    final showResult = widget.showResult;
    final isCorrect = widget.isCorrect;
    final questionTypeText = widget.question.type.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionTypeText,
          style: const TextStyle(
            color: Color(0xFFB0B4BB),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          widget.question.options.length,
          (index) => _buildOptionItem(index, showResult, isCorrect),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOptionItem(int index, bool showResult, bool? isCorrect) {
    final isSelected = widget.selectedIndexes.contains(index);
    final isWrong = (showResult && isSelected && isCorrect == false) || (widget.wrongIndexes != null && widget.wrongIndexes!.contains(index));
    Color? fillColor = const Color(0xFFF7F9FC);
    BoxBorder? border;
    if (isSelected && !showResult) {
      fillColor = const Color(0xFFEFFFC3);
      border = Border.all(color: const Color(0xFF97CB06), width: 1.5);
    }
    if (isWrong) {
      fillColor = const Color(0xFFFFE6E6);
      border = Border.all(color: const Color(0xFFFF3B30), width: 1.5);
    }
    if (showResult && isSelected && isCorrect == true) {
      fillColor = const Color(0xFFEFFFC3); // фон как при выборе
      border = Border.all(color: const Color(0xFF97CB06), width: 1.5);
    }
    return GestureDetector(
      onTap: showResult
          ? null
          : () {
              widget.onAnswered(false, [index]);
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          children: [
            CustomRadio(
              selected: isSelected,
              showResult: showResult,
              isRight: showResult && isSelected && isCorrect == true,
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
