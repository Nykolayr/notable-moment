import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_label.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    this.label,
    this.hintText = '',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.backgroundColor = AppColor.bgText00,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Color backgroundColor;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  String? _errorText;

  void _validate(String value) {
    setState(() {
      _errorText = widget.validator?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColor.bgText300),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) AppLabel(widget.label!),
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: border.borderRadius,
          ),
          child: TextFormField(
            controller: widget.controller,
            autovalidateMode: widget.autovalidateMode,
            style: AppStyle.body.bgText900,
            keyboardType: widget.keyboardType,
            onChanged: _validate,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppStyle.body.bgText500,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColor.primary)),
              errorBorder: border.copyWith(borderSide: BorderSide(color: AppColor.error)),
              focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: AppColor.error)),
            ),
          ),
        ),
        if (_errorText != null) ...[const SizedBox(height: 2), Text(_errorText!, style: AppStyle.subtext.error)],
      ],
    );
  }
}
