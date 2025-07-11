import 'package:flutter/material.dart';
import 'beginning_few_words_screen.dart';

class BeginningAcceptScreen extends StatefulWidget {
  const BeginningAcceptScreen({super.key});

  @override
  State<BeginningAcceptScreen> createState() => _BeginningAcceptScreenState();
}

class _BeginningAcceptScreenState extends State<BeginningAcceptScreen> {
  int? selectedIndex;

  final List<String> answers = ['Нет', 'Да'];
  final int correctIndex = 1; // "Да"

  @override
  Widget build(BuildContext context) {
    final bool showLabel = selectedIndex == correctIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верх
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Выйти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF4D7CFE)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.lightbulb_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Монеты и энергия
                  Row(
                    children: const [
                      Text('🪙 13', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 12),
                      Text('⚡', style: TextStyle(fontSize: 22, color: Colors.orange)),
                      Text('⚡', style: TextStyle(fontSize: 22, color: Color(0xFFE1E7F3))),
                      Text('⚡', style: TextStyle(fontSize: 22, color: Color(0xFFE1E7F3))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Выбери правильный вариант ответа.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Осло – столица Норвегии.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 40),

                  if (showLabel)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FFD0),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Верно!  +1 🪙',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF71A300),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Кнопки выбора
                  Row(
                    children: List.generate(2, (index) {
                      final bool isSelected = selectedIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 42,
                            margin: EdgeInsets.only(right: index == 0 ? 12 : 0),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF0FFD0) : const Color(0xFFF9FAFC),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8AC926) : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              answers[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? const Color(0xFF8AC926) : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Кнопка "Далее"
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedIndex != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BeginningFewWordsScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D7CFE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Далее',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
