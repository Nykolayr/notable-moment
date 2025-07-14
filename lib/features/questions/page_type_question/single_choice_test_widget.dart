import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';

class SingleChoiceTestWidget extends StatefulWidget {
  final SingleChoiceQuestion question;
  const SingleChoiceTestWidget({super.key, required this.question});

  @override
  State<SingleChoiceTestWidget> createState() => _SingleChoiceTestWidgetState();
}

class _SingleChoiceTestWidgetState extends State<SingleChoiceTestWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          widget.question.options.length,
          (index) => _buildOptionItem(index),
        ),
      ],
    );
  }

  Widget _buildOptionItem(int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F1FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF2F80ED) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isCorrect() {
    return selectedIndex == widget.question.correctIndex;
  }
}
