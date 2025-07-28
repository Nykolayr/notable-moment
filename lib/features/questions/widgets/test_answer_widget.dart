import 'package:flutter/material.dart';

class TestAnswerWidget extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final List<int>? selectedIndexes;
  final bool isMultiple;
  final bool answered;
  final VoidCallback onAnswer;
  final ValueChanged<int> onSelect;
  final ValueChanged<List<int>>? onSelectMultiple;
  final String buttonText;
  const TestAnswerWidget({
    super.key,
    required this.options,
    this.selectedIndex,
    this.selectedIndexes,
    required this.isMultiple,
    required this.answered,
    required this.onAnswer,
    required this.onSelect,
    this.onSelectMultiple,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...options.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;
          return ListTile(
            title: Text(text),
            leading: isMultiple
                ? Checkbox(
                    value: selectedIndexes?.contains(idx) ?? false,
                    onChanged: (v) {
                      if (onSelectMultiple != null) {
                        final newList = List<int>.from(selectedIndexes ?? []);
                        if (v == true) {
                          newList.add(idx);
                        } else {
                          newList.remove(idx);
                        }
                        onSelectMultiple!(newList);
                      }
                    },
                  )
                : Radio<int>(
                    value: idx,
                    groupValue: selectedIndex,
                    onChanged: (v) {
                      if (v != null) onSelect(v);
                    },
                  ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: answered ? onAnswer : null,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
