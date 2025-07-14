import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';

class GeneralTestWidget extends StatelessWidget {
  final GeneralQuestion question;
  final void Function(bool isCorrect, List<int> selected) onAnswered;
  final void Function(List<int> selected)? onSelectionChanged;
  final List<int> selectedIndexes;
  final bool showResult;
  final bool? isCorrect;
  final List<int>? wrongIndexes;
  const GeneralTestWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    this.onSelectionChanged,
    required this.selectedIndexes,
    this.showResult = false,
    this.isCorrect,
    this.wrongIndexes,
  });

  @override
  Widget build(BuildContext context) {
    final questionTypeText = question.type.text;
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
          question.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
        ),
        const SizedBox(height: 24),
        // Чип результата
        if (showResult && isCorrect != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCorrect! ? const Color(0xFFE6F9E2) : const Color(0xFFFFE6E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isCorrect! ? 'Верно! +1 🪙' : 'Неверно! -1 ⚡',
                style: TextStyle(
                  color: isCorrect! ? const Color(0xFF97CB06) : const Color(0xFFFF3B30),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Кнопки Да/Нет
        Row(
          children: [
            _buildOptionButton(context, 0, 'Да'),
            const SizedBox(width: 12),
            _buildOptionButton(context, 1, 'Нет'),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(BuildContext context, int index, String label) {
    final isSelected = selectedIndexes.contains(index);
    final isWrong =
        (showResult && isSelected && isCorrect == false) || (wrongIndexes != null && wrongIndexes!.contains(index));
    final isRight = showResult && isSelected && isCorrect == true;
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
    if (isRight) {
      fillColor = const Color(0xFFEFFFC3);
      border = Border.all(color: const Color(0xFF97CB06), width: 1.5);
    }
    return Expanded(
      child: GestureDetector(
        onTap: showResult
            ? null
            : () {
                if (onSelectionChanged != null) {
                  onSelectionChanged!([index]);
                }
              },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(8),
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isWrong
                  ? const Color(0xFFFF3B30)
                  : isRight
                      ? const Color(0xFF97CB06)
                      : const Color(0xFF222222),
            ),
          ),
        ),
      ),
    );
  }
}
