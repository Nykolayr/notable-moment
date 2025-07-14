import 'package:flutter/material.dart';

class AnswerResultChip extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onHide;
  const AnswerResultChip({super.key, required this.isCorrect, required this.onHide});

  @override
  State<AnswerResultChip> createState() => _AnswerResultChipState();
}

class _AnswerResultChipState extends State<AnswerResultChip> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onHide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.isCorrect;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isCorrect ? const Color(0xFFEFFFC3) : const Color(0xFFFFE6E6),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCorrect ? 'Верно!  +1' : 'Неверно!  -1',
              style: TextStyle(
                color: isCorrect ? const Color(0xFF97CB06) : const Color(0xFFFF3B30),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            isCorrect
                ? Image.asset('assets/image/suscoin.png', width: 28, height: 28)
                : Icon(Icons.flash_on, color: Color(0xFFFFB800), size: 28),
          ],
        ),
      ),
    );
  }
}
