import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/page_type_question/single_choice_test_widget.dart';
import 'package:notable_moments/features/questions/page_type_question/multiple_choice_test_widget.dart';
import 'package:notable_moments/features/questions/widgets/profile_stats_bar.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:collection/collection.dart';
import 'package:notable_moments/features/questions/widgets/top_progress_bar.dart';
import 'package:notable_moments/features/questions/widgets/test_answer_widget.dart';
import 'package:notable_moments/features/questions/widgets/energy_recharge_widget.dart';
import 'package:notable_moments/features/questions/widgets/route_finish_widget.dart';

class PageTestScreen extends ConsumerStatefulWidget {
  final RouteModel route;
  final int currentIndex;

  const PageTestScreen({super.key, required this.route, required this.currentIndex});

  @override
  ConsumerState<PageTestScreen> createState() => _PageTestScreenState();
}

enum TestStep { question, result, finish }

class _PageTestScreenState extends ConsumerState<PageTestScreen> {
  int currentTestIndex = 0;
  List<bool> results = [];
  int? selectedIndex;
  List<int> selectedIndexes = [];
  bool? isCorrect;
  int localEnergy = 3;
  int localSuscoins = 10;
  bool answered = false; // Был ли выбран ответ (для смены кнопки)
  bool showRecharge = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    localEnergy = profile.energy;
    localSuscoins = profile.suscoins;
  }

  void _onSelectSingle(int idx) {
    setState(() {
      selectedIndex = idx;
      answered = true;
    });
  }

  void _onSelectMultiple(List<int> idxs) {
    setState(() {
      selectedIndexes = idxs;
      answered = idxs.isNotEmpty;
    });
  }

  void _onAnswer(QuestionTest currentTest, QuestionTypeTest type, List<QuestionTest> tests) {
    if (!answered) return;
    bool correct = false;
    if (type == QuestionTypeTest.singleChoice) {
      correct = selectedIndex == (currentTest as SingleChoiceQuestion).correctIndex;
    } else if (type == QuestionTypeTest.multipleChoice) {
      final correctIndexes = (currentTest as MultipleChoiceQuestion).correctIndexes;
      final sortedSelected = List<int>.from(selectedIndexes)..sort();
      final sortedCorrect = List<int>.from(correctIndexes)..sort();
      correct = const ListEquality().equals(sortedSelected, sortedCorrect);
    }
    setState(() {
      isCorrect = correct;
      results.add(correct);
      if (correct) {
        localSuscoins += 1;
      } else {
        localEnergy = (localEnergy - 1).clamp(0, 3);
        if (localEnergy == 0) {
          showRecharge = true;
        }
      }
    });
  }

  void _onNext(List<QuestionTest> tests) {
    if (currentTestIndex == tests.length - 1) {
      setState(() {
        answered = false;
        isCorrect = null;
        selectedIndex = null;
        selectedIndexes = [];
        showRecharge = false;
      });
      // Переход к финалу
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            body: RouteFinishWidget(
              correctCount: results.where((e) => e).length,
              total: tests.length,
              suscoins: localSuscoins,
              energy: localEnergy,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    } else {
      setState(() {
        currentTestIndex++;
        answered = false;
        isCorrect = null;
        selectedIndex = null;
        selectedIndexes = [];
        showRecharge = false;
      });
    }
  }

  void _onBuyEnergy() {
    setState(() {
      if (localSuscoins > 0) {
        localSuscoins -= 1;
        localEnergy = 1;
        showRecharge = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.route.points;
    final tests = points[widget.currentIndex].tests;
    final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
    final type = currentTest?.type ?? QuestionTypeTest.singleChoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TopProgressBar(
                current: currentTestIndex + 1,
                total: tests.length,
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              child: ProfileStatsBar(
                suscoins: localSuscoins,
                energy: localEnergy,
                onAddSuscoin: () {},
                onAddEnergy: () {},
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                type.text,
                style: const TextStyle(
                  color: Color(0xFF8F99A8),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Gap(4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                currentTest?.text ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            const Gap(18),
            if (showRecharge)
              Expanded(
                child: EnergyRechargeWidget(
                  suscoins: localSuscoins,
                  energy: localEnergy,
                  onBuy: _onBuyEnergy,
                  onClose: () => Navigator.of(context).pop(),
                ),
              )
            else if (currentTest != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: type == QuestionTypeTest.singleChoice
                      ? SingleChoiceTestWidget(
                          question: currentTest as SingleChoiceQuestion,
                          selectedIndex: selectedIndex,
                          showResult: isCorrect != null,
                          isCorrect: isCorrect,
                          onAnswered: (_, idx) {
                            setState(() {
                              selectedIndex = idx;
                              answered = true;
                            });
                          },
                        )
                      : MultipleChoiceTestWidget(
                          question: currentTest as MultipleChoiceQuestion,
                          selectedIndexes: selectedIndexes,
                          showResult: isCorrect != null,
                          isCorrect: isCorrect,
                          onAnswered: (_, idxs) {
                            setState(() {
                              selectedIndexes = List<int>.from(idxs);
                              answered = selectedIndexes.isNotEmpty;
                            });
                          },
                        ),
                ),
              )
            else
              const Expanded(
                child: Center(child: Text('Нет доступных тестов')),
              ),
            const Gap(12),
            // --- Кнопка ---
            if (!showRecharge && currentTest != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: AppButton(
                  title:
                      (selectedIndex != null || (selectedIndexes.isNotEmpty && type == QuestionTypeTest.multipleChoice))
                          ? (currentTestIndex == tests.length - 1 ? 'Завершить' : 'Далее')
                          : 'Ответить',
                  onTap:
                      (selectedIndex != null || (selectedIndexes.isNotEmpty && type == QuestionTypeTest.multipleChoice))
                          ? () {
                              if (isCorrect == null) {
                                _onAnswer(currentTest, type, tests);
                              } else {
                                _onNext(tests);
                              }
                            }
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
