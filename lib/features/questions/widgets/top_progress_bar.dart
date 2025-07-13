import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopProgressBar extends StatelessWidget {
  final double progress;
  final VoidCallback onExit;
  const TopProgressBar({super.key, required this.progress, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onExit,
          child: const Text(
            'Выйти',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE7EAF3),
              valueColor: AlwaysStoppedAnimation(Color(0xFF4A90E2)),
            ),
          ),
        ),
      ],
    );
  }
}
