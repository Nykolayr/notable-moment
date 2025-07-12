// lib/features/routes/admin/edit_test_screen.dart

import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/question.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'firestore_test_repository.dart';
import 'models/questions/question.dart';

class EditTestScreenOld extends StatefulWidget {
  final QuestionTest test;

  const EditTestScreenOld({
    super.key,
    required this.test,
  });

  @override
  State<EditTestScreenOld> createState() => _EditTestScreenOldState();
}

class _EditTestScreenOldState extends State<EditTestScreenOld> {
  final repo = FirestoreTestRepository();
  final uuid = const Uuid();

  List<QuestionOld> questions = [];
  bool isLoading = true;

  final List<TextEditingController> questionControllers = [];
  final List<TextEditingController> answerControllers = [];
  final List<List<TextEditingController>> optionControllers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => isLoading = true);

    questionControllers.clear();
    answerControllers.clear();
    optionControllers.clear();

    for (var q in questions) {
      questionControllers.add(TextEditingController(text: q.text));
      answerControllers.add(TextEditingController(text: q.correctAnswer));
      optionControllers.add(q.options.map((o) => TextEditingController(text: o)).toList());
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    for (var c in questionControllers) {
      c.dispose();
    }
    for (var c in answerControllers) {
      c.dispose();
    }
    for (var list in optionControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void addQuestion() {
    setState(() {
      final newId = uuid.v4();
      final newQ = QuestionOld(
        id: newId,
        type: QuestionTypeOld.single,
        text: '',
        options: [''],
        correctAnswer: '',
        correctIndexes: [0], // ✅ добавлено
      );
      questions.add(newQ);
      questionControllers.add(TextEditingController());
      answerControllers.add(TextEditingController());
      optionControllers.add([TextEditingController()]);
    });
  }

  void saveTest() async {
    List<QuestionOld> updatedQuestions = [];
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];

      final updatedOptions = optionControllers[i].map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();

      // Вычисляем индексы правильных ответов
      final correctAnswerText = answerControllers[i].text.trim();
      final correctIndexes = <int>[];
      for (int j = 0; j < updatedOptions.length; j++) {
        if (updatedOptions[j] == correctAnswerText) {
          correctIndexes.add(j);
        }
      }

      final updatedQuestion = QuestionOld(
        id: q.id,
        type: q.type,
        text: questionControllers[i].text.trim(),
        options: updatedOptions,
        correctAnswer: correctAnswerText,
        correctIndexes: correctIndexes,
      );

      updatedQuestions.add(updatedQuestion);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тест успешно сохранён')),
    );
  }

  void deleteQuestion(int index) {
    setState(() {
      questions.removeAt(index);
      questionControllers.removeAt(index).dispose();
      answerControllers.removeAt(index).dispose();
      optionControllers.removeAt(index).forEach((c) => c.dispose());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование теста'),
        actions: [
          IconButton(
            onPressed: saveTest,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final qController = questionControllers[index];
          final aController = answerControllers[index];
          final oControllers = optionControllers[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: qController,
                    decoration: const InputDecoration(labelText: 'Вопрос'),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Варианты ответов:'),
                      const SizedBox(height: 8),
                      ...List.generate(oControllers.length, (optIdx) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: oControllers[optIdx],
                                decoration: InputDecoration(
                                  hintText: 'Вариант ${optIdx + 1}',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  oControllers.removeAt(optIdx).dispose();
                                });
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        );
                      }),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            oControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить вариант'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: aController,
                        decoration: const InputDecoration(labelText: 'Правильный ответ (текст)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => deleteQuestion(index),
                      icon: const Icon(Icons.delete),
                      label: const Text('Удалить вопрос'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Добавить вопрос'),
      ),
    );
  }
}
