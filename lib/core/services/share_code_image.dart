import "dart:io";
import "dart:ui" as ui;

import "package:code_forge/code_forge.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:share_plus/share_plus.dart";

import "../../constants.dart";
import "../providers/settings_provider.dart";
import "../providers/workspace_provider.dart";
import "../utils/show_message.dart";

class ShareAsImageService {
  static Future<void> shareCodeAsImage(BuildContext context) async {
    final workspace = context.read<WorkspaceProvider>();
    final code = workspace.codeController;
    final lines = code.text.split("\n");

    if (lines.isEmpty || code.text.isEmpty) {
      showMessage("لا يوجد كود للمشاركة");
      return;
    }

    try {
      final image = await _captureCodeAsImage(
        code,
        context.read<SettingsProvider>().get(AppSetting.fontSize),
        workspace.selectedFile.name,
      );

      if (image == null) {
        if (context.mounted) {
          showMessage("فشل في إنشاء الصورة");
        }
        return;
      }

      final downloadsDir = await _getDownloadsDirectory();
      final fileName =
          "${workspace.selectedFile.name.replaceAll(RegExp(r'\.[^.]+$'), '')}_code.png";
      final filePath = "${downloadsDir.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(image);

      if (kIsWeb) {
        showMessage("المشاركة غير مدعومة على الويب");
        return;
      }

      if (Platform.isLinux) {
        await Process.run("xdg-open", [filePath]);
        showMessage("تم فتح الصورة: $filePath");
        return;
      }

      await Share.shareXFiles([
        XFile(filePath),
      ], text: "كود ${workspace.selectedFile.name}");
    } catch (e) {
      debugPrint("share error: $e");
      showMessage("${l10n.error} في المشاركة: $e");
    }
  }

  static Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory() ??
          await getTemporaryDirectory();
    }
    if (Platform.isLinux) {
      final home = Platform.environment["HOME"] ?? "/tmp";
      final downloads = Directory("$home/Downloads");
      if (await downloads.exists()) {
        return downloads;
      }
      return Directory(home);
    }
    return await getTemporaryDirectory();
  }

  static Future<Uint8List?> _captureCodeAsImage(
    CodeForgeController code,
    double fontSize,
    String fileName,
  ) async {
    final lines = code.text.split("\n");

    const lineHeight = 1.6;
    const padding = 32.0;
    const headerHeight = 60.0;
    const lineNumberWidth = 50.0;

    double maxLineWidth = 0;
    for (var line in lines) {
      final lp = TextPainter(
        text: TextSpan(
          text: line,
          style: TextStyle(fontSize: fontSize, fontFamily: kMainFont),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      if (lp.width > maxLineWidth) maxLineWidth = lp.width;
    }

    final width = (maxLineWidth + padding * 2 + lineNumberWidth).clamp(
      400.0,
      1600.0,
    );
    final height =
        lines.length * fontSize * lineHeight + headerHeight + padding * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF1A2340),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, headerHeight + padding),
      Paint()..color = const Color(0xFF252D4A),
    );

    final headerTextPainter = TextPainter(
      text: TextSpan(
        text: fileName,
        style: TextStyle(
          color: Colors.white70,
          fontSize: fontSize * 0.9,
          fontFamily: kMainFont,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    headerTextPainter.paint(
      canvas,
      Offset(padding, padding + (headerHeight - headerTextPainter.height) / 2),
    );

    const codeStartY = headerHeight + padding;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final y = codeStartY + (i * fontSize * lineHeight);

      final lineNumberPainter = TextPainter(
        text: TextSpan(
          text: "${i + 1}",
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: fontSize * 0.8,
            fontFamily: kMainFont,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      lineNumberPainter.paint(
        canvas,
        Offset(
          width - padding - lineNumberPainter.width,
          y + (fontSize * lineHeight - lineNumberPainter.height) / 2,
        ),
      );

      final linePainter = TextPainter(
        text: TextSpan(
          text: line,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontFamily: kMainFont,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      )..layout();

      linePainter.paint(
        canvas,
        Offset(
          width - padding - lineNumberWidth - linePainter.width,
          y + (fontSize * lineHeight - linePainter.height) / 2,
        ),
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }
}
