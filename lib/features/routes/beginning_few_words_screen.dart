import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/admin/test_context.dart';

class BeginningFewWordsScreen extends ConsumerStatefulWidget {
  const BeginningFewWordsScreen({super.key});

  @override
  ConsumerState<BeginningFewWordsScreen> createState() => _BeginningFewWordsScreenState();
}

class _BeginningFewWordsScreenState extends ConsumerState<BeginningFewWordsScreen> {
  int currentQuestionIndex = 0;
  List<List<bool>> selectedOptions = [];
  List<String> textAnswers = [];
  List<Question> questions = [];
  bool isLoading = true;
  final repo = FirestoreTestRepository();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // TODO: testId должен быть передан в экран или получен из контекста маршрута
    const testId = 'dci004xsXJdGM7yRhp2o';
    final loaded = await repo.fetchQuestions(testId);
    setState(() {
      questions = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Нет доступных вопросов')));
    }
    final Question question = questions[currentQuestionIndex];

    if (selectedOptions.length != questions.length) {
      selectedOptions = List.generate(
        questions.length,
        (i) => List<bool>.filled(questions[i].options.length, false),
      );
    }

    if (textAnswers.length != questions.length) {
      textAnswers = List.generate(questions.length, (_) => '');
    }

    final selected = selectedOptions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        value: (currentQuestionIndex + 1) / questions.length,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF4D7CFE)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Text('🪙 12', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text('⚡⚡⚡', style: TextStyle(fontSize: 22)),
                  Spacer(),
                  Icon(Icons.lightbulb_outline),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                question.type == QuestionType.multiple
                    ? 'Выбери несколько правильных ответов.'
                    : question.type == QuestionType.single
                        ? 'Выбери один правильный ответ.'
                        : 'Введи текстовый ответ.',
                style: const TextStyle(
                  color: Color(0xFF9199A1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              if (question.type == QuestionType.text)
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Введите ответ...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    textAnswers[currentQuestionIndex] = val;
                  },
                  controller: TextEditingController(text: textAnswers[currentQuestionIndex]),
                )
              else
                ...List.generate(question.options.length, (index) {
                  final isSelected = selected[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (question.type == QuestionType.single) {
                          selectedOptions[currentQuestionIndex] = List<bool>.filled(question.options.length, false);
                          selectedOptions[currentQuestionIndex][index] = true;
                        } else {
                          selectedOptions[currentQuestionIndex][index] = !selectedOptions[currentQuestionIndex][index];
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FFD0) : const Color(0xFFF9FAFC),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8AC926) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF8AC926) : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8AC926) : const Color(0xFF4D7CFE),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentQuestionIndex < questions.length - 1) {
                          setState(() => currentQuestionIndex++);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D7CFE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        currentQuestionIndex == questions.length - 1 ? 'Ответить' : 'Далее',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
