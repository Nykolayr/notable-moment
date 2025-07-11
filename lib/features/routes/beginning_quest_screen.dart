import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // ✅ Для listEquals
import 'package:notable_moments/features/routes/admin/firestore_test_repository.dart';
import 'package:notable_moments/features/routes/admin/firestore_user_test_repository.dart';
import 'package:notable_moments/features/routes/admin/models/questions/question.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart'; // для получения userId

class BeginningQuestScreen extends ConsumerStatefulWidget {
  final String testId;
  final String pointId;
  final String nextPointId;

  const BeginningQuestScreen({
    super.key,
    required this.testId,
    required this.pointId,
    required this.nextPointId,
  });

  @override
  ConsumerState<BeginningQuestScreen> createState() => _BeginningQuestScreenState();
}

class _BeginningQuestScreenState extends ConsumerState<BeginningQuestScreen> {
  final repo = FirestoreTestRepository();
  final userTestRepo = FirestoreUserTestRepository();

  List<QuestionOld> questions = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool isFinished = false;
  int correctCount = 0;

  List<List<bool>> selectedOptions = [];
  List<TextEditingController> textControllers = [];

  int coins = 0; // 🪙
  int energy = 3; // ⚡⚡⚡

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final fetched = await repo.fetchQuestions(widget.testId);
    setState(() {
      questions = fetched;
      selectedOptions = fetched.map((q) => List.generate(q.options.length, (_) => false)).toList();
      textControllers = fetched.map((_) => TextEditingController()).toList();
      isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var c in textControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> evaluateAnswers() async {
    correctCount = 0;
    final answers = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      String userAnswer = '';
      bool isCorrect = false;

      if (q.type == QuestionTypeOld.text) {
        userAnswer = textControllers[i].text.trim();
        isCorrect = q.correctAnswer.toLowerCase().trim() == userAnswer.toLowerCase();
        if (isCorrect) {
          correctCount++;
          coins++;
        }
      } else {
        final userSelection = selectedOptions[i];
        final userIndexes =
            List.generate(userSelection.length, (idx) => idx).where((idx) => userSelection[idx]).toList();
        final correctIndexes = q.correctIndexes;
        isCorrect = listEquals(correctIndexes, userIndexes);
        if (isCorrect) {
          correctCount++;
          coins++;
        }
        userAnswer = userIndexes.map((e) => q.options[e]).join(', ');
      }

      answers.add({
        'questionId': q.id,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
      });
    }

    final userId = ref.watch(profileProvider).uid; // ✅ исправлено

    // Сохраняем прогресс теста
    await userTestRepo.saveUserTestProgress(
      userId: userId,
      testId: widget.testId,
      pointId: widget.pointId,
      score: correctCount,
      maxScore: questions.length,
      answers: answers,
    );

    // Разблокируем следующую точку
    await userTestRepo.unlockNextPoint(
      userId: userId,
      pointId: widget.nextPointId,
    );

    setState(() {
      isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Квест')),
        body: const Center(child: Text('Нет доступных вопросов для этого квеста')),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🪙'),
            const SizedBox(width: 4),
            Text('$coins'),
            const SizedBox(width: 12),
            Text('⚡' * energy),
            const Spacer(),
            const Text('💡'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              color: Colors.blue,
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              q.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (q.type == QuestionTypeOld.text)
              TextField(
                controller: textControllers[currentIndex],
                decoration: const InputDecoration(
                  labelText: 'Введите ваш ответ',
                  border: OutlineInputBorder(),
                ),
              ),
            if (q.type != QuestionTypeOld.text)
              ...List.generate(q.options.length, (index) {
                return CheckboxListTile(
                  value: selectedOptions[currentIndex][index],
                  title: Text(q.options[index]),
                  onChanged: isFinished
                      ? null
                      : (val) {
                          setState(() {
                            if (q.type == QuestionTypeOld.single) {
                              selectedOptions[currentIndex] = List.generate(q.options.length, (_) => false);
                              selectedOptions[currentIndex][index] = val ?? false;
                            } else {
                              selectedOptions[currentIndex][index] = val ?? false;
                            }
                          });
                        },
                );
              }),
            const Spacer(),
            if (isFinished)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Отличная работа!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Верных ответов: $correctCount из ${questions.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (isFinished) {
                    Navigator.of(context).pop(true);
                  } else if (currentIndex < questions.length - 1) {
                    setState(() {
                      currentIndex++;
                    });
                  } else {
                    await evaluateAnswers();
                  }
                },
                child: Text(
                  isFinished ? 'Закрыть' : (currentIndex < questions.length - 1 ? 'Далее' : 'Завершить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
