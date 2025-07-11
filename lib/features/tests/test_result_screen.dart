import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/features/routes/model/question_model.dart';

class TestResultScreen extends ConsumerWidget {
  final List<Question4> questions;
  final Map<String, dynamic> userAnswers;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const TestResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.onRetry,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int correctAnswers = questions.where((q) {
      final userAnswer = userAnswers[q.id];
      if (userAnswer == null) return false;
      if (q.type == QuestionType.single || q.type == QuestionType.multiple) {
        return q.correctAnswers.contains(userAnswer);
      } else if (q.type == QuestionType.text) {
        return q.correctAnswers
            .any((answer) => answer.toLowerCase().trim() == (userAnswer as String).toLowerCase().trim());
      }
      return false;
    }).length;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Результаты теста'),
        backgroundColor: AppColor.primary, // Исправлено здесь
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Вы правильно ответили на $correctAnswers из ${questions.length} вопросов.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final userAnswer = userAnswers[q.id];
                  final bool isCorrect = () {
                    if (userAnswer == null) return false;
                    if (q.type == QuestionType.single || q.type == QuestionType.multiple) {
                      return q.correctAnswers.contains(userAnswer);
                    } else if (q.type == QuestionType.text) {
                      return q.correctAnswers
                          .any((answer) => answer.toLowerCase().trim() == (userAnswer as String).toLowerCase().trim());
                    }
                    return false;
                  }();

                  return Card(
                    color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                    child: ListTile(
                      title: Text(q.text), // Оставлено 'q.text', если в модели есть title — заменить на q.title
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Ваш ответ: ${userAnswer ?? 'нет ответа'}',
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Правильный ответ: ${q.correctAnswers.join(", ")}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Пройти тест снова'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Продолжить маршрут'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
