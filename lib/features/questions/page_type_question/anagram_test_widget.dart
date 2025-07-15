// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';

class AnagramTestWidget extends StatefulWidget {
  final AnagramQuestion question;
  final List<String?> userAnswer;
  final List<String?> bank;
  final void Function(int fromRow, int fromIdx, int toRow, int toIdx)? onMove;
  final bool showResult;
  final bool? isCorrect;
  const AnagramTestWidget({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.bank,
    this.onMove,
    this.showResult = false,
    this.isCorrect,
  });

  @override
  State<AnagramTestWidget> createState() => _AnagramTestWidgetState();
}

class _AnagramTestWidgetState extends State<AnagramTestWidget> {
  int? draggingRow; // 0 — верх, 1 — низ
  int? draggingIdx;
  String? draggingLetter;

  @override
  Widget build(BuildContext context) {
    final showResult = widget.showResult;
    final isCorrect = widget.isCorrect;
    final question = widget.question;
    final userAnswer = widget.userAnswer;
    final bank = widget.bank;
    final questionTypeText = question.type.text;

    // Стили
    Color getBorderColor(int i) {
      if (!showResult) return const Color(0xFFE0E0E0);
      if (isCorrect == true && userAnswer[i] != null) return const Color(0xFF97CB06);
      if (isCorrect == false && userAnswer[i] != null) return const Color(0xFFFF3B30);
      return const Color(0xFFE0E0E0);
    }

    Color? getFillColor(int i) {
      if (!showResult) return null;
      if (isCorrect == true && userAnswer[i] != null) return const Color(0xFFEFFFC3);
      if (isCorrect == false && userAnswer[i] != null) return const Color(0xFFFFE6E6);
      return null;
    }

    Widget buildRow(List<String?> row, int rowNum, {bool isAnswer = false}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(row.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Column(
                  children: [
                    // Квадратик с буквой над черточкой
                    if (row[i] != null)
                      Draggable<String>(
                        data: '$rowNum:$i:${row[i]!.toLowerCase()}',
                        feedback: _buildLetter(row[i]!, dragging: true),
                        childWhenDragging: const SizedBox(width: 34, height: 40),
                        onDragStarted: () {
                          setState(() {
                            draggingRow = rowNum;
                            draggingIdx = i;
                            draggingLetter = row[i];
                          });
                        },
                        onDraggableCanceled: (_, __) {
                          setState(() {
                            draggingRow = null;
                            draggingIdx = null;
                            draggingLetter = null;
                          });
                        },
                        onDragEnd: (_) {
                          setState(() {
                            draggingRow = null;
                            draggingIdx = null;
                            draggingLetter = null;
                          });
                        },
                        child: _buildLetter(row[i]!),
                      )
                    else
                      const SizedBox(width: 34, height: 40),
                    const SizedBox(height: 8),
                    // Увеличенная область захвата с черточкой
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                        width: 42,
                        height: 2,
                        margin: const EdgeInsets.symmetric(vertical: 9),
                        color: const Color(0xFFE0E0E0),
                      ),
                    ),
                  ],
                );
              },
              onWillAcceptWithDetails: (data) => true,
              onAcceptWithDetails: (data) {
                final parts = data.toString().split(':');
                final fromRow = int.parse(parts[0]);
                final fromIdx = int.parse(parts[1]);
                if (widget.onMove != null) {
                  widget.onMove!(fromRow, fromIdx, rowNum, i);
                }
                setState(() {
                  draggingRow = null;
                  draggingIdx = null;
                  draggingLetter = null;
                });
              },
            ),
          );
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Инструкция
        Text(
          questionTypeText,
          style: const TextStyle(
            color: Color(0xFFB0B4BB),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        // Вопрос
        Text(
          question.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
        ),
        const SizedBox(height: 32), // Увеличенный отступ перед черточками
        // Верхний ряд (ответ)
        buildRow(userAnswer, 0, isAnswer: true),
        const SizedBox(height: 32),
        // Нижний ряд (банк)
        buildRow(bank, 1),
      ],
    );
  }

  Widget _buildLetter(String letter, {bool dragging = false}) {
    return Container(
      width: 34,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dragging ? Colors.grey[300] : const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Text(
        letter.toLowerCase(),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
      ),
    );
  }
}
