import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:notable_moments/core/widget/app_card.dart';
import 'package:notable_moments/features/routes/model/route_model.dart';

class RouteScreen extends ConsumerWidget {
  final String routeId;

  const RouteScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeDoc = FirebaseFirestore.instance.collection('routes').doc(routeId);

    return AppScaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: routeDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Маршрут не найден'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final route = RouteModel.fromMap(data, snapshot.data!.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                title: route.title,
                subtitle: route.description,
              ),
              const SizedBox(height: 16),
              const Text(
                'Точки маршрута:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (route.points.isEmpty)
                const Text('Нет точек в этом маршруте')
              else
                ...route.points.map(
                  (point) => ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(point.name),
                    subtitle: Text(point.description ?? ''),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
