import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EnergyRechargeV2Widget extends StatelessWidget {
  final int energy; // 0-3
  final int suscoins;
  final String suslikName;
  final String suslikImage; // путь к картинке
  final VoidCallback? onBuy;
  final VoidCallback? onFinish;
  final bool buyEnabled;
  final String buyText;
  final String finishText;

  const EnergyRechargeV2Widget({
    super.key,
    required this.energy,
    required this.suscoins,
    required this.suslikName,
    required this.suslikImage,
    this.onBuy,
    this.onFinish,
    this.buyEnabled = true,
    this.buyText = 'Пополнить',
    this.finishText = 'Завершить маршрут',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 340,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Не удалось открыть новое место',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF222222),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Суслику нужна энергия, покормите его…',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF8F99A8),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(18),
            Image.asset(
              suslikImage,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const Gap(8),
            Text(
              'Суслик $suslikName',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF222222),
              ),
            ),
            const Gap(12),
            // Прогресс-бар энергии
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EnergyBar(energy: energy),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Image.asset('assets/image/suscoin.png', width: 22, height: 22),
                    const SizedBox(width: 4),
                    Text(
                      suscoins.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: buyEnabled ? onBuy : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buyEnabled ? const Color(0xFF466BFF) : const Color(0xFFE7EAF3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      buyText,
                      style: TextStyle(
                        color: buyEnabled ? Colors.white : const Color(0xFFBFC6D1),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onFinish,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF466BFF), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      finishText,
                      style: const TextStyle(
                        color: Color(0xFF466BFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final int energy;
  const _EnergyBar({required this.energy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.flash_on,
            color: i < energy ? const Color(0xFFFFB800) : const Color(0xFFE1E9F4),
            size: 24,
          ),
        );
      }),
    );
  }
}
