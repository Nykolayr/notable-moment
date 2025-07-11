import 'package:flutter/material.dart';
import 'package:notable_moments/core/extension/build_context_extension.dart';
import 'package:notable_moments/core/theme/app_color.dart';
import 'package:notable_moments/core/theme/app_style.dart';
import 'package:notable_moments/core/widget/app_button.dart';

Future<void> appButtonDeleteDialog({
  required String title,
  String? description,
  String? canselText = 'Отмена',
  String? okText = 'Удалить',
  VoidCallback? okCallBack,
  AppButtonStyle okStyle = AppButtonStyle.red,
  required BuildContext context,
}) =>
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColor.bgText00, borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title, style: AppStyle.subheader2.bgText900),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(description, style: AppStyle.body.bgText900),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppButton(
                        title: canselText,
                        style: AppButtonStyle.white,
                        onTap: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        title: okText,
                        style: okStyle,
                        onTap: () {
                          context.pop();
                          okCallBack?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
