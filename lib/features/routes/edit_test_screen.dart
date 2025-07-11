import 'package:flutter/material.dart';

enum QuestionType { single, multiple, text, pair }

class PairModel {
  String left;
  String right;

  PairModel({this.left = '', this.right = ''});
}

class QuestionModel {
  QuestionType type;
  String question;
  List<String> options;
  Set<int> correctIndexes;
  String correctAnswerText;
  List<PairModel> pairs;

  QuestionModel({
    required this.type,
    required this.question,
    this.options = const [],
    this.correctIndexes = const {},
    this.correctAnswerText = '',
    this.pairs = const [],
  });
}

class EditTestScreen extends StatefulWidget {
  final List<QuestionModel> initialQuestions;
  final Function(List<QuestionModel>) onSave;

  const EditTestScreen({
    super.key,
    required this.initialQuestions,
    required this.onSave,
  });

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late List<QuestionModel> questions;

  @override
  void initState() {
    super.initState();
    questions = [...widget.initialQuestions];
  }

  void addNewQuestion() {
    setState(() {
      questions.add(QuestionModel(type: QuestionType.single, question: ''));
    });
  }

  void save() {
    widget.onSave(questions);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование теста'),
        actions: [
          TextButton(
            onPressed: save,
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Вопрос'),
                    onChanged: (val) => q.question = val,
                    controller: TextEditingController(text: q.question),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<QuestionType>(
                    value: q.type,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          q.type = val;
                          q.options = [];
                          q.correctIndexes = {};
                          q.correctAnswerText = '';
                          q.pairs = [];
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: QuestionType.single,
                        child: Text('Один правильный ответ'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.multiple,
                        child: Text('Несколько правильных ответов'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.text,
                        child: Text('Текстовый ответ'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.pair,
                        child: Text('Пары'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (q.type == QuestionType.text)
                    TextField(
                      decoration: const InputDecoration(labelText: 'Правильный ответ'),
                      onChanged: (val) => q.correctAnswerText = val,
                      controller: TextEditingController(text: q.correctAnswerText),
                    )
                  else if (q.type == QuestionType.pair)
                    Column(
                      children: [
                        ...List.generate(q.pairs.length, (i) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(hintText: 'Левая часть'),
                                  onChanged: (val) => q.pairs[i].left = val,
                                  controller: TextEditingController(text: q.pairs[i].left),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.compare_arrows),
                              ),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(hintText: 'Правая часть'),
                                  onChanged: (val) => q.pairs[i].right = val,
                                  controller: TextEditingController(text: q.pairs[i].right),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    q.pairs.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          );
                        }),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              q.pairs.add(PairModel());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить пару'),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        ...List.generate(q.options.length, (optIndex) {
                          return Row(
                            children: [
                              if (q.type == QuestionType.single)
                                Radio<int>(
                                  value: optIndex,
                                  groupValue: q.correctIndexes.isEmpty ? null : q.correctIndexes.first,
                                  onChanged: (val) {
                                    setState(() {
                                      q.correctIndexes = {val!};
                                    });
                                  },
                                ),
                              if (q.type == QuestionType.multiple)
                                Checkbox(
                                  value: q.correctIndexes.contains(optIndex),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        q.correctIndexes.add(optIndex);
                                      } else {
                                        q.correctIndexes.remove(optIndex);
                                      }
                                    });
                                  },
                                ),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(hintText: 'Вариант'),
                                  onChanged: (val) => q.options[optIndex] = val,
                                  controller: TextEditingController(text: q.options[optIndex]),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    q.options.removeAt(optIndex);
                                    q.correctIndexes.remove(optIndex);
                                  });
                                },
                              ),
                            ],
                          );
                        }),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              q.options.add('');
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить вариант'),
                        ),
                      ],
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          questions.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
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
        onPressed: addNewQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Добавить вопрос'),
      ),
    );
  }
}
