import 'package:flutter/material.dart';
import 'package:notable_moments/features/questions/model/question_type.dart';

class EditTestScreen extends StatefulWidget {
  final dynamic test;

  const EditTestScreen({super.key, required this.test});

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late QuestionTypeTest _type;
  late dynamic _questionData;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _type = widget.test.type;
    _questionData = widget.test;
  }

  void _onTypeChanged(QuestionTypeTest? newType) {
    if (newType == null) return;
    setState(() {
      _type = newType;
      _questionData = null;
      _isValid = false;
    });
  }

  void _onQuestionChanged(dynamic data, bool isValid) {
    setState(() {
      _questionData = data;
      _isValid = isValid;
    });
  }

  void _onSave() {
    Navigator.of(context).pop(_questionData);
  }

  void _onBack() {
    Navigator.of(context).pop(_questionData);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Создание вопроса'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<QuestionTypeTest>(
                value: _type,
                onChanged: _onTypeChanged,
                items: QuestionTypeTest.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.title),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _type.buildEditor(
                  initial: _questionData,
                  onChanged: _onQuestionChanged,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _onSave : null,
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
