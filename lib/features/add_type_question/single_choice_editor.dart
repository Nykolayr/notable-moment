import 'package:flutter/material.dart';

class SingleChoiceEditor extends StatefulWidget {
  final dynamic initial;
  final void Function(dynamic data, bool isValid) onChanged;

  const SingleChoiceEditor({super.key, this.initial, required this.onChanged});

  @override
  State<SingleChoiceEditor> createState() => _SingleChoiceEditorState();
}

class _SingleChoiceEditorState extends State<SingleChoiceEditor> {
  late dynamic data;

  @override
  void initState() {
    super.initState();
    data = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _notify() {
    // Здесь должна быть валидация для SingleChoiceData, если потребуется
    widget.onChanged(data, true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Редактор: Один вариант'));
  }
}
