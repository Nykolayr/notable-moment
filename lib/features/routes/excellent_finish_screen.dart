import 'package:flutter/material.dart';

class ExcellentFinishScreen extends StatelessWidget {
  const ExcellentFinishScreen({super.key});

  void onFinish(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void onNext(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.pushNamed(context, '/next-screen'); // Замените на актуальный маршрут
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Отличная работа!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  '🦫',
                  style: TextStyle(fontSize: 100),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '2 из 2 верных ответов',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🪙 +2', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text('⚡⚡⚡', style: TextStyle(fontSize: 22, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text('📷', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'река Енисей',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Читать о месте',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9199A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isActive = index == 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: isActive ? const Color(0xFF4D7CFE) : const Color(0xFFDCE2EE),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onFinish(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDFE3EA)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Завершить',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onNext(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D7CFE),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Идти дальше',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
