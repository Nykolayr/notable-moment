import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';
import 'package:notable_moments/features/questions/model/order_question.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/add_type_question/single_choice_editor.dart';
import 'package:notable_moments/features/add_type_question/multiple_choice_editor.dart';
import 'package:notable_moments/features/add_type_question/anagram_editor.dart';
import 'package:notable_moments/features/add_type_question/order_editor.dart';
import 'package:notable_moments/features/add_type_question/match_editor.dart';

class EditTestScreen extends StatefulWidget {
  final QuestionTest test;

  const EditTestScreen({super.key, required this.test});

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late Map<QuestionTypeTest, QuestionTest> _questionsByType;
  late QuestionTypeTest _selectedType;
  late QuestionTest _initialQuestion;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.test.type;
    _initialQuestion = widget.test;
    _questionsByType = {
      for (var type in QuestionTypeTest.values)
        type: _createQuestionOfType(type, initial: type == widget.test.type ? widget.test : null),
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
    Navigator.of(context).pop(_questionsByType[_selectedType]);
  }

  void _onBack() {
    Navigator.of(context).pop(_initialQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final current = _questionsByType[_selectedType];
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создание вопроса'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<QuestionTypeTest>(
                value: _selectedType,
                onChanged: _onTypeChanged,
                items: QuestionTypeTest.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.title),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (current is SingleChoiceQuestion)
                SingleChoiceEditor(
                  initial: current,
                  onChanged: (SingleChoiceQuestion q, bool valid) => _onQuestionChanged(q, valid),
                ),
              if (current is MultipleChoiceQuestion)
                MultipleChoiceEditor(
                  initial: current,
                  onChanged: (MultipleChoiceQuestion q, bool valid) => _onQuestionChanged(q, valid),
                ),
              if (current is AnagramQuestion)
                AnagramEditor(
                  initial: current,
                  onChanged: (AnagramQuestion q, bool valid) => _onQuestionChanged(q, valid),
                ),
              if (current is OrderQuestion)
                OrderEditor(
                  initial: current,
                  onChanged: (OrderQuestion q, bool valid) => _onQuestionChanged(q, valid),
                ),
              if (current is PairQuestion)
                MatchEditor(
                  initial: current,
                  onChanged: (PairQuestion q, bool valid) => _onQuestionChanged(q, valid),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _onSave : null,
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
