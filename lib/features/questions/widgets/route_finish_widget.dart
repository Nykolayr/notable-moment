import 'package:flutter/material.dart';

class RouteFinishWidget extends StatelessWidget {
  final int correctCount;
  final int total;
  final int suscoins;
  final int energy;
  final VoidCallback onClose;
  const RouteFinishWidget({
    super.key,
    required this.correctCount,
    required this.total,
    required this.suscoins,
    required this.energy,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: реализовать UI по макету фигмы
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Отличная работа!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('$correctCount из $total верных ответов', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: Colors.amber),
              SizedBox(width: 4),
              Text('$suscoins', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Icon(Icons.flash_on, color: Colors.orange),
              SizedBox(width: 4),
              Text('$energy', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: onClose,
            child: Text('Завершить'),
          ),
        ],
      ),
    );
  }
}
