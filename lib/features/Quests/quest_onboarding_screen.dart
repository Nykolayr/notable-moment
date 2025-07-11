import 'package:flutter/material.dart';

class QuestOnboardingScreen extends StatefulWidget {
  const QuestOnboardingScreen({super.key});

  @override
  State<QuestOnboardingScreen> createState() => _QuestOnboardingScreenState();
}

class _QuestOnboardingScreenState extends State<QuestOnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> pages = [
    _OnboardingData(
      title: 'Выбирай вариант ответа',
      description: 'Решай задания верно с первого раза и получай сускоины!',
      emoji: '🐿️ +1',
      subEmoji: '🥇🥇',
    ),
    _OnboardingData(
      title: 'Береги очки энергии',
      description: 'За каждую ошибку будет отниматься 1 ⚡ энергия.',
      emoji: '⚡ -1',
    ),
    _OnboardingData(
      title: 'Используй подсказки',
      description: 'Ты можешь купить подсказку за сускоины, чтобы решить задание быстрее.',
      emoji: '💡 +1 🐿️',
    ),
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _skip() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 64),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (page.subEmoji != null) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              page.subEmoji!,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                            (dotIndex) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dotIndex == _currentPage ? Colors.white : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _skip,
                              child: const Text(
                                'Пропустить',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _currentPage == pages.length - 1 ? 'В путь!' : 'Далее',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String emoji;
  final String? subEmoji;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.emoji,
    this.subEmoji,
  });
}
