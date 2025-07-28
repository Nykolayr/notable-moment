import 'package:flutter/material.dart';

class EnergyRechargeWidget extends StatelessWidget {
  final int suscoins;
  final int energy;
  final VoidCallback onBuy;
  final VoidCallback onClose;
  const EnergyRechargeWidget({
    super.key,
    required this.suscoins,
    required this.energy,
    required this.onBuy,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Энергия закончилась!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('У вас $suscoins сускоина(ов)'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onBuy,
            child: Text('Купить энергию'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onClose,
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
