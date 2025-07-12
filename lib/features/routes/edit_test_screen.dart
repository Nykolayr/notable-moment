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
import 'package:notable_moments/features/add_type_question/single_choice_editor.dart';
import 'package:notable_moments/features/add_type_question/multiple_choice_editor.dart';
import 'package:notable_moments/features/add_type_question/anagram_editor.dart';
import 'package:notable_moments/features/add_type_question/order_editor.dart';
import 'package:notable_moments/features/add_type_question/match_editor.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTap;

  const CustomAppBar({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 8, right: 16, top: 0, bottom: 0),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF222222)),
                onPressed: onTap ?? () => Navigator.of(context).maybePop(),
                splashRadius: 20,
                padding: const EdgeInsets.only(right: 8),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class EditTestScreen extends StatefulWidget {
  final QuestionTest test;

  const EditTestScreen({super.key, required this.test});

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
    _selectedType = widget.test.type;
    initialQuestion = widget.test;
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

    // Если это новый тест (id == 'empty'), генерируем уникальный ID
    if (currentQuestion?.id == 'empty') {
      final updatedQuestion = currentQuestion!.copyWith(id: _uuid.v4());
      Navigator.of(context).pop(updatedQuestion);
    } else {
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
        appBar: CustomAppBar(
          title: widget.test.id == 'empty' ? 'Создание вопроса' : 'Редактирование вопроса',
          onTap: _onBack, // _onBack возвращает нужный тест
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
                      if (current is SingleChoiceQuestion) {
                        return SingleChoiceEditor(
                          initial: current,
                          onChanged: (SingleChoiceQuestion q, bool valid) => _onQuestionChanged(q, valid),
                        );
                      }
                      if (current is MultipleChoiceQuestion) {
                        return MultipleChoiceEditor(
                          initial: current,
                          onChanged: (MultipleChoiceQuestion q, bool valid) => _onQuestionChanged(q, valid),
                        );
                      }
                      if (current is AnagramQuestion) {
                        return AnagramEditor(
                          initial: current,
                          onChanged: (AnagramQuestion q, bool valid) => _onQuestionChanged(q, valid),
                        );
                      }
                      if (current is OrderQuestion) {
                        return OrderEditor(
                          initial: current,
                          onChanged: (OrderQuestion q, bool valid) => _onQuestionChanged(q, valid),
                        );
                      }
                      if (current is PairQuestion) {
                        return MatchEditor(
                          initial: current,
                          onChanged: (PairQuestion q, bool valid) => _onQuestionChanged(q, valid),
                        );
                      }
                      return const SizedBox.shrink();
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
