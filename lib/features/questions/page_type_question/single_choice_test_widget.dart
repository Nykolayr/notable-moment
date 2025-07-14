import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'widgets/custom_radio.dart';

class SingleChoiceTestWidget extends StatefulWidget {
  final SingleChoiceQuestion question;
  final void Function(bool isCorrect, int? selected) onAnswered;
  final bool showResult;
  final bool? isCorrect;
  final int? selectedIndex;
  final int? wrongIndex;
  const SingleChoiceTestWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.showResult = false,
    this.isCorrect,
    this.selectedIndex,
    this.wrongIndex,
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
    final isSelected = widget.selectedIndex == index;
    print('SingleChoiceTestWidget: option $index, isSelected: $isSelected, showResult: $showResult');
    final isWrong =
        (showResult && isSelected && isCorrect == false) || (widget.wrongIndex != null && widget.wrongIndex == index);
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
              print('SingleChoiceTestWidget: onTap $index');
              widget.onAnswered(false, index);
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
