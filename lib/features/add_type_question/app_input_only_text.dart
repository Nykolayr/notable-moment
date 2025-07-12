import 'package:flutter/material.dart';

/// AppInputOnlyText
///
/// Кастомный текстовый инпут только для текста, с крестиком для очистки.
/// Используется для ввода вопроса и вариантов ответа в редакторах тестов.
/// Стиль: белый фон, скругления, светлая рамка, placeholder серый.
class AppInputOnlyText extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final bool selected;

  const AppInputOnlyText({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B8), fontSize: 18),
        filled: true,
        fillColor: selected ? Color(0xFFF1FFCC) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: selected ? Color(0xFFA3D421) : Color(0xFFE0E4EA), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: selected ? Color(0xFFA3D421) : Color(0xFFE0E4EA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: selected ? Color(0xFFA3D421) : Color(0xFF2563EB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        isDense: true,
        suffixIcon: (controller.text.isNotEmpty && enabled)
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  if (onChanged != null) onChanged!("");
                },
                child: const Icon(Icons.close, size: 20, color: Color(0xFFB0B0B8)),
              )
            : null,
      ),
    );
  }
}
