import "dart:io";

import "package:archive/archive.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

import "../../constants.dart";
import "../../features/terminal/provider/terminal_provider.dart";
import "../helpers/hive_helper.dart";
import "../models/data_typs.dart";
import "../providers/settings_provider.dart";

Future<void> setupAlif(BuildContext context) async {
  final terminal = context.read<TerminalProvider>();
  try {
    final installedVersion =
        HiveHelper.getData<String>(kBoxSettings, kKeyAlifVersion) ?? "";
    final bool needsUpdate = installedVersion != kAlifVersion;
    final String updateMessage =
        "${l10n.successUpdateAlifVersionFrom} $installedVersion ${l10n.to} $kAlifVersion";

    final appDir = await getApplicationSupportDirectory();
    final alifDir = Directory("${appDir.path}/alif");
    final libDir = Directory("${alifDir.path}/library");

    if (needsUpdate && await alifDir.exists()) {
      await alifDir.delete(recursive: true);
    }

    if (!await alifDir.exists()) await alifDir.create(recursive: true);
    if (!await libDir.exists()) await libDir.create(recursive: true);

    String alifPath = "";
    String platformAssetPrefix = "";

    if (Platform.isAndroid) {
      platformAssetPrefix = "assets/aliflang/arm64-v8a/";
      alifPath = "${alifDir.path}/libalif.so";
    } else if (Platform.isLinux) {
      platformAssetPrefix = "assets/aliflang/linux/alif/";
      alifPath = "${alifDir.path}/amd64";
    } else {
      return;
    }

    if (needsUpdate) {
      // 1. فك ضغط مجلد المكتبات
      final zipData = await rootBundle.load("assets/aliflang/library.zip");
      final bytes = zipData.buffer.asUint8List();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final outFile = File("${libDir.path}/$filename");
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>, flush: true);
        }
      }

      // 2. نسخ ملفات المنصة
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final platformAssets = manifest
          .listAssets()
          .where((key) => key.startsWith(platformAssetPrefix))
          .toList();

      final copiedBinaries = <String>[];

      await Future.wait(
        platformAssets.map((assetPath) async {
          final assetData = await rootBundle.load(assetPath);
          final binBytes = assetData.buffer.asUint8List();

          final relativePath = assetPath.substring(platformAssetPrefix.length);
          final targetFile = File("${alifDir.path}/$relativePath");

          await targetFile.parent.create(recursive: true);
          await targetFile.writeAsBytes(binBytes, flush: true);

          copiedBinaries.add(targetFile.path);
        }),
      );

      // 3. صلاحيات التشغيل
      if (Platform.isLinux || Platform.isAndroid || Platform.isMacOS) {
        for (final filePath in copiedBinaries) {
          final isBinary =
              filePath.endsWith(".so") ||
              filePath.endsWith("_lsp") ||
              !filePath.split("/").last.contains(".");
          if (isBinary) {
            await Process.run("chmod", ["+x", filePath]);
          }
        }
      }

      await HiveHelper.saveData<String>(
        kBoxSettings,
        key: kKeyAlifVersion,
        kAlifVersion,
      );

      if (installedVersion.isNotEmpty) terminal.addOutput(updateMessage);
    }

    // حفظ المسار وتأكيده
    if (alifPath.isNotEmpty && await File(alifPath).exists()) {
      if (!context.mounted) return;
      final settings = context.read<SettingsProvider>();
      settings.set(AppSetting.alifBinPath, alifPath);
      if (needsUpdate) {
        terminal.addOutput("${l10n.successInstallAlifVersion} $kAlifVersion");
      }
    } else {
      terminal.addOutput(
        "الملف التنفيذي غير موجود في المسار: $alifPath",
        type: LineType.error,
      );
    }
  } catch (e, s) {
    terminal.addOutput("$e", type: LineType.error);
    debugPrint("${l10n.error}: $e\n$s");
  }
}
