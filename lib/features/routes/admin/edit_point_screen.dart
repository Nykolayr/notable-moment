// lib/features/routes/admin/edit_point_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/routes/edit_test_screen.dart';
import 'package:notable_moments/features/routes/model/point_admin_model.dart';
import 'package:notable_moments/features/routes/provider/points_provider.dart';

class EditPointScreen extends ConsumerStatefulWidget {
  final PointAdminModel point;

  const EditPointScreen({
    super.key,
    required this.point,
  });

  @override
  ConsumerState<EditPointScreen> createState() => _EditPointScreenState();
}

class _EditPointScreenState extends ConsumerState<EditPointScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.point.title);
    _descriptionController = TextEditingController(text: widget.point.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointsNotifier = ref.read(pointsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.point.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedPoint = widget.point.copyWith(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
              );
              pointsNotifier.updatePoint(updatedPoint);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название точки'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание точки'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditTestScreen(
                      test: widget.point.test,
                    ),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Квест сохранён')),
                  );
                }
              },
              icon: const Text('🧪', style: TextStyle(fontSize: 20)),
              label: const Text('Добавить / Редактировать квест'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
