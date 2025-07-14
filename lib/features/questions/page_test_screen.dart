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
import 'package:notable_moments/features/questions/widgets/answer_result_chip.dart';
import 'package:notable_moments/features/profile/provider/user_progress_provider.dart';
import 'package:notable_moments/features/questions/widgets/modals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notable_moments/features/profile/model/user_progress.dart';

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
  bool showChip = false; // Показывать ли чип результата
  int? wrongIndex; // Индекс неправильного выбора для single
  List<int> wrongIndexes = []; // Индексы неправильных для multiple
  bool hintUsedThisTest = false;

  void _showResultChip() {
    setState(() {
      showChip = true;
    });
  }

  void _hideResultChip() {
    setState(() {
      showChip = false;
    });
  }

  void _useHint(String routeId) {
    setState(() {
      hintUsedThisTest = true;
      final points = widget.route.points;
      final tests = points[widget.currentIndex].tests;
      final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
      final type = currentTest?.type ?? QuestionTypeTest.singleChoice;
      if (type == QuestionTypeTest.singleChoice) {
        selectedIndex = (currentTest as SingleChoiceQuestion).correctIndex;
      } else if (type == QuestionTypeTest.multipleChoice) {
        selectedIndexes = List<int>.from((currentTest as MultipleChoiceQuestion).correctIndexes);
      }
      isCorrect = true; // сразу показываем кнопку "Далее"
      answered = true;
      showChip = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    localEnergy = profile.energy;
    localSuscoins = profile.suscoins;
    // --- Инициализация подсказок на маршрут ---
    final routeId = widget.route.id;
    final userProgress = ref.read(userProgressProvider);
    final routeProgress = userProgress.routes[routeId];
    if (routeProgress == null || routeProgress.hintsLeft == null) {
      Future.microtask(() {
        final userProgress = ref.read(userProgressProvider);
        final userProgressNotifier = ref.read(userProgressProvider.notifier);
        final routeProgress = userProgress.routes[routeId];
        final newRouteProgress = RouteProgress(
          completedPlaces: routeProgress?.completedPlaces ?? {},
          completedQuests: routeProgress?.completedQuests ?? {},
          hintsLeft: 3,
        );
        final newRoutes = Map<String, RouteProgress>.from(userProgress.routes);
        newRoutes[routeId] = newRouteProgress;
        userProgressNotifier.state = userProgress.copyWith(routes: newRoutes);
      });
    }
  }

  void _onSelectSingle(int idx) {
    setState(() {
      selectedIndex = idx;
      answered = true;
      wrongIndex = null; // Сбросить ошибку при новом выборе
      isCorrect = null; // Сбросить результат при новом выборе
    });
  }

  void _onSelectMultiple(List<int> idxs) {
    setState(() {
      selectedIndexes = idxs;
      answered = idxs.isNotEmpty;
      wrongIndexes = []; // Сбросить ошибку при новом выборе
      isCorrect = null; // Сбросить результат при новом выборе
    });
  }

  void _onAnswer(QuestionTest currentTest, QuestionTypeTest type, List<QuestionTest> tests) {
    if (hintUsedThisTest) return; // если была подсказка — ничего не делаем
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
      showChip = !hintUsedThisTest; // Не показывать чип при подсказке
      if (!correct) {
        if (type == QuestionTypeTest.singleChoice) {
          wrongIndex = selectedIndex;
        } else if (type == QuestionTypeTest.multipleChoice) {
          wrongIndexes = List<int>.from(selectedIndexes);
        }
      }
      if (correct && !hintUsedThisTest) {
        localSuscoins += 1;
      } else if (!correct) {
        localEnergy = (localEnergy - 1).clamp(0, 3);
        if (localEnergy == 0) {
          showRecharge = true;
        }
      }
    });
  }

  void _onNext(List<QuestionTest> tests) {
    setState(() {
      showChip = false;
      wrongIndex = null;
      wrongIndexes = [];
    });
    if (currentTestIndex == tests.length - 1) {
      setState(() {
        answered = false;
        isCorrect = null;
        selectedIndex = null;
        selectedIndexes = [];
        showRecharge = false;
      });
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

  VoidCallback? getButtonAction(QuestionTest? currentTest, QuestionTypeTest type, List<QuestionTest> tests) {
    if (!(selectedIndex != null || (selectedIndexes.isNotEmpty && type == QuestionTypeTest.multipleChoice))) {
      return null;
    }

    if (isCorrect == null) {
      return () {
        _onAnswer(currentTest!, type, tests);
        _showResultChip();
      };
    } else if (isCorrect == true) {
      return () {
        _onNext(tests);
      };
    } else {
      return () {
        setState(() {
          isCorrect = null;
          showChip = false;
        });
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.route.points;
    final tests = points[widget.currentIndex].tests;
    final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
    final type = currentTest?.type ?? QuestionTypeTest.singleChoice;
    final routeId = widget.route.id;
    final userProgress = ref.watch(userProgressProvider);
    final routeProgress = userProgress.routes[routeId];
    final hintsLeft = routeProgress?.hintsLeft ?? 3;
    final suscoins = userProgress.suscoins;
    final userProgressNotifier = ref.read(userProgressProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    suscoins: suscoins,
                    energy: localEnergy,
                    onAddSuscoin: () {},
                    onAddEnergy: () {},
                    onHintPressed: () async {
                      await showBuyHintModal(
                        context,
                        hintsLeft: hintsLeft,
                        onBuy: () {
                          // НЕ уменьшаем hintsLeft для теста!
                          // final updatedRouteProgress = routeProgress?.copyWith(hintsLeft: hintsLeft - 1) ?? RouteProgress(completedPlaces: {}, completedQuests: {}, hintsLeft: hintsLeft - 1);
                          // final newRoutes = Map<String, RouteProgress>.from(userProgress.routes);
                          // newRoutes[routeId] = updatedRouteProgress;
                          // userProgressNotifier.state = userProgress.copyWith(
                          //   suscoins: suscoins - 1,
                          //   routes: newRoutes,
                          // );
                          _useHint(routeId);
                        },
                      );
                    },
                    hintsLeft: hintsLeft,
                    hintUsedThisTest: hintUsedThisTest,
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
                              showResult: isCorrect == true,
                              isCorrect: isCorrect,
                              wrongIndex: wrongIndex,
                              onAnswered: (_, idx) {
                                setState(() {
                                  selectedIndex = idx;
                                  answered = true;
                                  wrongIndex = null;
                                  isCorrect = null; // Сбрасываем результат при новом выборе
                                });
                              },
                            )
                          : MultipleChoiceTestWidget(
                              question: currentTest as MultipleChoiceQuestion,
                              selectedIndexes: selectedIndexes,
                              showResult: isCorrect == true,
                              isCorrect: isCorrect,
                              wrongIndexes: wrongIndexes,
                              onAnswered: (_, idxs) {
                                setState(() {
                                  selectedIndexes = List<int>.from(idxs);
                                  answered = selectedIndexes.isNotEmpty;
                                  wrongIndexes = [];
                                  isCorrect = null; // Сбрасываем результат при новом выборе
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
                      title: isCorrect == true
                          ? (currentTestIndex == tests.length - 1 ? 'Завершить' : 'Далее')
                          : 'Ответить',
                      onTap: getButtonAction(currentTest, type, tests),
                    ),
                  ),
              ],
            ),
            if (showChip && isCorrect != null)
              AnswerResultChip(
                isCorrect: isCorrect!,
                onHide: _hideResultChip,
              ),
          ],
        ),
      ),
    );
  }
}
