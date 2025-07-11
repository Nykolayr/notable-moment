import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_gesture_detector.dart';
import 'package:notable_moments/core/widget/app_input.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';

class AppDropdownFullscreenScreen extends StatefulWidget {
  const AppDropdownFullscreenScreen({super.key, required this.values});

  final List<String> values;

  @override
  State<AppDropdownFullscreenScreen> createState() => _AppDropdownFullscreenScreenState();
}

class _AppDropdownFullscreenScreenState extends State<AppDropdownFullscreenScreen> {
  final searchController = TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(listener);
  }

  void listener() {
    setState(() {
      searchText = searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(listener);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filteredValues = widget.values.where((v) => v.toLowerCase().contains(searchText)).toList();
    return AppScaffold(
      appBar: AppAppBar(title: 'Выбор образовательной организации', showClose: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14), //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: AppInput(controller: searchController, hintText: 'Поиск'),
          ),
          const SizedBox(height: 10),
          AppGestureDetector(
            onTap: () => context.pop(null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text('Не выбрано', style: AppStyle.body.bgText900),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredValues.length, //
              itemBuilder: (context, index) => AppGestureDetector(
                onTap: () => context.pop(filteredValues[index]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(filteredValues[index], style: AppStyle.body.bgText900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
