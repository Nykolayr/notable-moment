import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onExit;
  const TopProgressBar({super.key, required this.current, required this.total, required this.onExit});

  @override
  Widget build(BuildContext context) {
    print('current: $current, total: $total');
    final double progress = current / total;
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
