import 'package:flutter/material.dart';
import 'package:notable_moments/features/routes/excellent_finish_screen.dart';
import 'package:notable_moments/features/routes/admin/test_context.dart';

class BeginningFinalScreen extends StatefulWidget {
  const BeginningFinalScreen({super.key});

  @override
  State<BeginningFinalScreen> createState() => _BeginningFinalScreenState();
}

class _BeginningFinalScreenState extends State<BeginningFinalScreen> {
  final List<String> answers = ['Ответ №1', 'Ответ №2', 'Ответ №3', 'Ответ №4'];
  final Set<int> correctIndexes = {0, 3};
  final Set<int> selectedIndexes = {};
  bool answerSubmitted = false;
  List<Question> questions = []; // Из test_context.dart

  void handleAnswer() {
    if (!answerSubmitted) {
      final isCorrect = selectedIndexes.length == correctIndexes.length && selectedIndexes.containsAll(correctIndexes);
      if (!isCorrect) {
        Navigator.pop(context, false);
        return;
      }
      setState(() {
        answerSubmitted = true;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ExcellentFinishScreen(),
        ),
      ).then((_) {
        Navigator.pop(context, true);
      });
    }
  }

  void toggleAnswer(int index) {
    if (answerSubmitted) return;
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Шапка
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Выйти',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: LinearProgressIndicator(
                            value: 1.0,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF4D7CFE)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lightbulb_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text('🪙 11', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 12),
                      Text('⚡⚡⚡', style: TextStyle(fontSize: 22, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Выбери несколько правильных ответов.',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Текст текст текст текст вопроса?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Список ответов
                  Expanded(
                    child: ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final bool isSelected = selectedIndexes.contains(index);
                        final bool isCorrect = correctIndexes.contains(index);
                        final Color bgColor = answerSubmitted
                            ? (isCorrect
                                ? Colors.green.withOpacity(.2)
                                : (isSelected ? Colors.red.withOpacity(.2) : const Color(0xFFF9FAFC)))
                            : (isSelected ? const Color(0xFFF0FFD0) : const Color(0xFFF9FAFC));
                        final Color borderColor = answerSubmitted
                            ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.transparent))
                            : (isSelected ? const Color(0xFF8AC926) : Colors.transparent);
                        final Color textColor = answerSubmitted
                            ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.black))
                            : (isSelected ? const Color(0xFF8AC926) : Colors.black);

                        return GestureDetector(
                          onTap: () => toggleAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected && !answerSubmitted ? const Color(0xFF8AC926) : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected && !answerSubmitted
                                          ? const Color(0xFF8AC926)
                                          : const Color(0xFF4D7CFE),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: !answerSubmitted && isSelected
                                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    answers[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Отступ перед кнопкой
            Positioned(
              bottom: 72,
              left: 16,
              right: 16,
              child: const SizedBox(height: 10),
            ),

            // Кнопка действия
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedIndexes.isEmpty ? null : handleAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D7CFE),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    answerSubmitted ? 'Далее' : 'Ответить',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
