import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notable_moments/core/theme/app_icon.dart';
import 'package:notable_moments/core/widget/app_app_bar.dart';
import 'package:notable_moments/core/widget/app_button.dart';
import 'package:notable_moments/core/widget/app_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ProfilePdf extends StatelessWidget {
  const ProfilePdf({super.key, required this.title, required this.asset});
  final String title;
  final String asset;

  Future<void> _downloadAndShare() async {
    try {
      final bytes = await rootBundle.load(asset);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${asset.split('/').last}');
      await tempFile.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
        ),
      );
    } catch (e) {
      debugPrint('Ошибка при попытке поделиться PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: title,
        actions: [
          AppButton.icon(
            icon: AppIcon.download,
            onTap: _downloadAndShare,
            style: AppButtonStyle.white,
          ),
        ],
      ),
      body: SfPdfViewer.asset(asset),
    );
  }
}
