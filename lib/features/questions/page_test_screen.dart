// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/features/questions/model/question.dart';
import 'package:notable_moments/features/questions/model/single_choice_question.dart';
import 'package:notable_moments/features/questions/model/multiple_choice_question.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';
import 'package:notable_moments/features/questions/widgets/profile_stats_bar.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';
import 'package:collection/collection.dart';
import 'package:notable_moments/features/questions/widgets/top_progress_bar.dart';
import 'package:notable_moments/features/questions/widgets/route_finish_widget.dart';
import 'package:notable_moments/features/questions/widgets/answer_result_chip.dart';
import 'package:notable_moments/features/profile/provider/profile_provider.dart';
import 'package:notable_moments/features/questions/widgets/modals.dart';
import 'package:notable_moments/features/questions/widgets/energy_recharge_page.dart';
import 'package:notable_moments/features/questions/model/general_question.dart';
import 'package:notable_moments/features/questions/model/true_false_question.dart';
import 'package:notable_moments/features/questions/model/anagram_question.dart';
import 'package:notable_moments/features/questions/page_type_question/pair_test_widget.dart';
import 'package:notable_moments/features/questions/model/pair_question.dart';
import 'package:notable_moments/features/profile/provider/user_progress_provider.dart';
import 'package:notable_moments/features/routes/admin/progress_provider.dart';

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
  bool answered = false; // Был ли выбран ответ (для смены кнопки)
  bool showRecharge = false;
  bool showChip = false; // Показывать ли чип результата
  int? wrongIndex; // Индекс неправильного выбора для single
  List<int> wrongIndexes = []; // Индексы неправильных для multiple
  bool hintUsedThisTest = false;
  List<String?>? anagramUserAnswer;
  List<String>? anagramBank;
  bool pairButtonActive = false;
  ValueNotifier<bool> pairCheckNotifier = ValueNotifier(false);
  bool allPairsCompleted = false;

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

  void _initAnagramState(AnagramQuestion anagram) {
    anagramUserAnswer = List<String?>.filled(anagram.answer.length, null);
    anagramBank = List<String>.from(anagram.letters.map((e) => e.toLowerCase()));
  }

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    final userProgress = ref.read(userProgressProvider);
    if (profile.energy == 0) {
      Future.microtask(() async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EnergyRechargePage(routeId: widget.route.id),
          ),
        );
      });
    }
    // --- Инициализация подсказок на маршрут ---
    final routeId = widget.route.id;
    final routeProgress = userProgress.routes[routeId];
    if (routeProgress == null) {
      Future.microtask(() {
        final userProgressNotifier = ref.read(userProgressProvider.notifier);
        userProgressNotifier.initializeRoute(routeId);
      });
    }
    // Инициализация для AnagramTestWidget
    final points = widget.route.points;
    final tests = points[widget.currentIndex].tests;
    final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
    if (currentTest != null && currentTest.type == QuestionTypeTest.anagram) {
      final anagram = currentTest as AnagramQuestion;
      anagramUserAnswer = List<String?>.filled(anagram.answer.length, null);
      anagramBank = List<String>.from(anagram.letters.map((e) => e.toLowerCase()));
    }
  }

  void onSelectSingle(int idx) {
    setState(() {
      selectedIndex = idx;
      answered = true;
      wrongIndex = null; // Сбросить ошибку при новом выборе
      isCorrect = null; // Сбросить результат при новом выборе
    });
  }

  void onSelectMultiple(List<int> idxs) {
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
    if (type == QuestionTypeTest.singleChoice ||
        type == QuestionTypeTest.general ||
        type == QuestionTypeTest.trueFalse) {
      final correctIndex = (type == QuestionTypeTest.singleChoice)
          ? (currentTest as SingleChoiceQuestion).correctIndex
          : (type == QuestionTypeTest.general)
              ? (currentTest as GeneralQuestion).correctIndex
              : ((currentTest as TrueFalseQuestion).correct ? 0 : 1);
      correct = const ListEquality().equals(selectedIndexes, [correctIndex]);
    } else if (type == QuestionTypeTest.multipleChoice) {
      final correctIndexes = (currentTest as MultipleChoiceQuestion).correctIndexes;
      final sortedSelected = List<int>.from(selectedIndexes)..sort();
      final sortedCorrect = List<int>.from(correctIndexes)..sort();
      correct = const ListEquality().equals(sortedSelected, sortedCorrect);
    }
    ref.read(userProgressProvider.notifier);
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
    });
    if (correct && !hintUsedThisTest) {
      ref.read(profileProvider.notifier).addSuscoins(1);
    } else if (!correct) {
      ref.read(profileProvider.notifier).spendEnergy(1);
      final profile = ref.read(profileProvider);
      if (profile.energy == 0) {
        Future.microtask(() async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EnergyRechargePage(routeId: widget.route.id),
            ),
          );
        });
      }
    }
  }

  void _onNext(List<QuestionTest> tests) async {
    setState(() {
      showChip = false;
      wrongIndex = null;
      wrongIndexes = [];
      if (tests.isNotEmpty &&
          tests[currentTestIndex + 1 < tests.length ? currentTestIndex + 1 : currentTestIndex].type ==
              QuestionTypeTest.anagram) {
        final nextTest =
            tests[currentTestIndex + 1 < tests.length ? currentTestIndex + 1 : currentTestIndex] as AnagramQuestion;
        _initAnagramState(nextTest);
      }
    });
    final points = widget.route.points;
    final isLastTestInPoint = currentTestIndex == tests.length - 1;
    final isLastPoint = widget.currentIndex == points.length - 1;
    final userProgressNotifier = ref.read(userProgressProvider.notifier);
    ref.read(userProgressProvider);
    final profile = ref.read(profileProvider);
    final routeId = widget.route.id;
    final placeId = points[widget.currentIndex].name;
    final suslikAsset = 'assets/image/sus_good.png'; // Можно сделать выбор по количеству правильных

    if (isLastTestInPoint) {
      // Сохраняем прогресс точки и начисляем сускоины
      userProgressNotifier.completePlace(routeId, placeId, profile.uid);

      // Также обновляем progressProvider для синхронизации с UI
      final progressNotifier = ref.read(progressProvider.notifier);
      progressNotifier.unlockNext(routeId);

      ref.read(profileProvider.notifier).addSuscoins(tests.length);
      if (isLastPoint) {
        // Это последняя точка маршрута — показываем итог маршрута
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              body: RouteFinishWidget(
                correctCount: results.where((e) => e).length,
                total: tests.length,
                suscoins: tests.length,
                energy: profile.energy,
                routeTitle: widget.route.title,
                onClose: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 3);
                },
              ),
            ),
          ),
        );
      } else {
        // Итог точки (квеста)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              body: QuestFinishWidget(
                correctCount: results.where((e) => e).length,
                total: tests.length,
                suscoins: tests.length,
                suslikAsset: suslikAsset,
                onFinish: () {
                  Future.microtask(() {
                    int count = 0;
                    if (context.mounted) {
                      Navigator.of(context).popUntil((_) => count++ >= 3);
                    }
                  });
                },
                onNext: () {
                  Future.microtask(() {
                    int count = 0;
                    if (context.mounted) {
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    }
                  });
                },
              ),
            ),
          ),
        );
      }
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

  VoidCallback? getButtonAction(QuestionTest? currentTest, QuestionTypeTest type, List<QuestionTest> tests) {
    if (selectedIndexes.isEmpty) {
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

  String _getButtonTitle(QuestionTest? currentTest, QuestionTypeTest type) {
    if (type == QuestionTypeTest.pair) {
      return allPairsCompleted ? 'Далее' : 'Ответить';
    }
    return isCorrect == true ? 'Далее' : 'Ответить';
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.route.points;
    final tests = points[widget.currentIndex].tests;
    final currentTest = tests.isNotEmpty ? tests[currentTestIndex] : null;
    final type = currentTest?.type ?? QuestionTypeTest.singleChoice;
    if (type == QuestionTypeTest.anagram && (anagramUserAnswer == null || anagramBank == null)) {
      _initAnagramState(currentTest as AnagramQuestion);
    }
    final routeId = widget.route.id;
    final userProgress = ref.watch(userProgressProvider);
    final routeProgress = userProgress.routes[routeId];
    final hintsLeft = routeProgress?.hintsLeft ?? 3;
    final profile = ref.watch(profileProvider);
    final suscoins = profile.suscoins;
    final energy = profile.energy;

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
                    energy: energy,
                    isAdmin: profile.isAdmin,
                    onAddSuscoin: () {
                      ref.read(profileProvider.notifier).addSuscoins(1);
                    },
                    onAddEnergy: () {
                      final notifier = ref.read(profileProvider.notifier);
                      final currentEnergy = ref.read(profileProvider).energy;
                      if (currentEnergy < 3) {
                        notifier.addEnergy(1);
                      }
                    },
                    onHintPressed: () async {
                      await showBuyHintModal(
                        context,
                        hintsLeft: hintsLeft,
                        onBuy: () {
                          // Списываем сускоин и уменьшаем количество подсказок
                          final userProgressNotifier = ref.read(userProgressProvider.notifier);
                          userProgressNotifier.spendSuscoinAndUpdateHints(routeId, hintsLeft - 1, profile.uid);
                          _useHint(routeId);
                        },
                      );
                    },
                    hintsLeft: hintsLeft,
                    hintUsedThisTest: hintUsedThisTest,
                  ),
                ),
                const Gap(18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: type == QuestionTypeTest.pair
                        ? PairTestWidget(
                            question: currentTest as PairQuestion,
                            onSelectionChanged: (selectedIndexes, canAnswer) {
                              setState(() {
                                pairButtonActive = canAnswer;
                                allPairsCompleted = false;
                              });
                            },
                            onPairChecked: (isCorrect, selectedIndexes) {
                              if (!isCorrect) {
                                ref.read(profileProvider.notifier).spendEnergy(1);
                                setState(() {
                                  showChip = true;
                                  this.isCorrect = false;
                                });
                                final userProgress = ref.read(profileProvider);
                                if (userProgress.energy == 0) {
                                  Future.microtask(() async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EnergyRechargePage(routeId: widget.route.id),
                                      ),
                                    );
                                  });
                                }
                              }
                            },
                            onAllPairsCompleted: () {
                              setState(() {
                                allPairsCompleted = true;
                                pairButtonActive = false;
                                showChip = true;
                                isCorrect = true;
                              });
                              ref.read(profileProvider.notifier).addSuscoins(1);
                            },
                            checkPairSignal: pairCheckNotifier,
                          )
                        : type.buildTestWidget(
                            currentTest!,
                            onAnswered: (isCorrect, selected) {
                              setState(() {
                                selectedIndexes = List<int>.from(selected);
                                this.isCorrect = isCorrect;
                                answered = selectedIndexes.isNotEmpty;
                                wrongIndex = null;
                              });
                            },
                            selectedIndexes: selectedIndexes,
                            showResult: isCorrect == true,
                            isCorrect: isCorrect,
                            wrongIndexes: wrongIndexes,
                            onSelectionChanged: (newList) {
                              setState(() {
                                selectedIndexes = List<int>.from(newList);
                                answered = selectedIndexes.isNotEmpty;
                              });
                            },
                          ),
                  ),
                ),
                const Gap(12),
                // --- Кнопка ---
                if (!showRecharge)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: type == QuestionTypeTest.pair
                        ? AppButton(
                            title: allPairsCompleted ? 'Далее' : 'Ответить',
                            onTap: allPairsCompleted
                                ? () {
                                    setState(() {
                                      showChip = false;
                                      isCorrect = null;
                                    });
                                    _onNext(tests);
                                  }
                                : (pairButtonActive
                                    ? () {
                                        pairCheckNotifier.value = true;
                                      }
                                    : null),
                          )
                        : AppButton(
                            title: _getButtonTitle(currentTest, type),
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
