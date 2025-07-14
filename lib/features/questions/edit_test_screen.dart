import 'package:flutter/material.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';
import 'package:notable_moments/features/questions/model/sentence_order_question.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class EditTestScreen extends StatefulWidget {
  final QuestionTest? test;

  const EditTestScreen({super.key, this.test});

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late Map<QuestionTypeTest, QuestionTest> _questionsByType;
  late QuestionTypeTest _selectedType;
  late QuestionTest initialQuestion;
  bool _isValid = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    initialQuestion = widget.test ?? SingleChoiceQuestion.init();
    _selectedType = initialQuestion.type;
    _questionsByType = {
      for (var type in QuestionTypeTest.values)
        type: _createQuestionOfType(type, initial: type == initialQuestion.type ? initialQuestion : null),
    };
  }

  QuestionTest _createQuestionOfType(QuestionTypeTest type, {QuestionTest? initial}) {
    switch (type) {
      case QuestionTypeTest.singleChoice:
        if (initial is SingleChoiceQuestion) return initial;
        return SingleChoiceQuestion.init().copyWith(
          id: initial?.id,
          text: initial?.text,
          points: initial?.points,
          hint: initial?.hint,
        );
      case QuestionTypeTest.multipleChoice:
        if (initial is MultipleChoiceQuestion) return initial;
        return MultipleChoiceQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          options: const [],
          correctIndexes: const [],
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.anagram:
        if (initial is AnagramQuestion) return initial;
        return AnagramQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          answer: '',
          letters: const [],
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.order:
        if (initial is OrderQuestion) return initial;
        return OrderQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          items: const [],
          correctOrder: const [],
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.pair:
        if (initial is PairQuestion) return initial;
        return PairQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          pairs: const [],
          correctPairs: const [],
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.general:
        if (initial is GeneralQuestion) return initial;
        return GeneralQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          options: const ['Да', 'Нет'],
          correctIndex: 0,
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.trueFalse:
        if (initial is TrueFalseQuestion) return initial;
        return TrueFalseQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          correct: true,
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
      case QuestionTypeTest.sentenceOrder:
        if (initial is SentenceOrderQuestion) return initial;
        return SentenceOrderQuestion(
          id: initial?.id ?? '',
          text: initial?.text ?? '',
          words: const [],
          correctOrder: const [],
          points: initial?.points ?? 1,
          hint: initial?.hint,
        );
    }
  }

  void _onTypeChanged(QuestionTypeTest? newType) {
    if (newType == null) return;
    setState(() {
      _selectedType = newType;
      _isValid = false;
    });
  }

  void _onQuestionChanged(QuestionTest updated, bool isValid) {
    setState(() {
      _questionsByType[_selectedType] = updated;
      _isValid = isValid;
    });
  }

  void _onSave() {
    final currentQuestion = _questionsByType[_selectedType];
    print('Сохраняем тест: ${currentQuestion?.text}');

    // Если это новый тест (id == 'empty'), генерируем уникальный ID
    if (currentQuestion?.id == 'empty') {
      final updatedQuestion = currentQuestion!.copyWith(id: _uuid.v4());
      print('Новый тест с ID: ${updatedQuestion.id}');
      Navigator.of(context).pop(updatedQuestion);
    } else {
      print('Обновляем существующий тест с ID: ${currentQuestion?.id}');
      Navigator.of(context).pop(currentQuestion);
    }
  }

  void _onBack() {
    Navigator.of(context).pop(initialQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final current = _questionsByType[_selectedType];
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F6),
        appBar: AppAppBar(
          title: initialQuestion.id == 'empty' ? 'Создание вопроса' : 'Редактирование вопроса',
          backButtonTap: _onBack,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E6)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<QuestionTypeTest>(
                        value: _selectedType,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onChanged: _onTypeChanged,
                        items: QuestionTypeTest.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(type.icon, color: const Color(0xFF222222)),
                                    const SizedBox(width: 10),
                                    Text(type.title, style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Builder(
                    builder: (_) {
                      final editor = _selectedType.buildEditor(
                        initial: current,
                        onChanged: (q, valid) => _onQuestionChanged(q, valid),
                      );
                      return editor;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: AppButton(
                  title: 'Сохранить',
                  onTap: _isValid ? _onSave : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
