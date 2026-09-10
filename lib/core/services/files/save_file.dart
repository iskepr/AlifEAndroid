import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../../features/terminal/provider/terminal_provider.dart";
import "../../helpers/hive_helper.dart";
import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";
import "../../utils/file_picker.dart";

Future<bool> saveFileToStorage(
  BuildContext context, {
  bool asNew = false,
  String rootPath = "/storage/emulated/0",
}) async {
  final workspace = context.read<WorkspaceProvider>();
  final terminal = context.read<TerminalProvider>();

  final selectedFile = workspace.selectedFile;

  if (selectedFile.id == -1 || (workspace.files.isEmpty)) {
    terminal.addOutput("لا يوجد ملف مفتوح للحفظ.");
    return false;
  }

  final code = workspace.codeController.text;
  final filesList = List<FileEntity>.from(workspace.files);
  final currentIndex = filesList.indexWhere(
    (file) => file.id == selectedFile.id,
  );

  if (selectedFile.path == null || selectedFile.path!.isEmpty || asNew) {
    final completer = Completer<String?>();

    final defaultName = (selectedFile.name.isEmpty)
        ? "شفرة"
        : selectedFile.name.replaceAll(RegExp(r"\.(الف|alif|aliflib)$"), "");

    final startDir =
        (selectedFile.path != null && selectedFile.path!.isNotEmpty)
        ? File(selectedFile.path!).parent.path
        : rootPath;

    await showFileManagerModal(
      context,
      (selectedPath) {
        if (!completer.isCompleted) completer.complete(selectedPath);
      },
      rootPath: rootPath,
      startPath: startDir,
      isSaveMode: true,
      defaultFileName: defaultName,
      onSave: (fullPath) {
        if (!completer.isCompleted) completer.complete(fullPath);
      },
    );

    final targetPath = await completer.future;

    if (targetPath == null || targetPath.isEmpty) {
      terminal.addOutput("تم إلغاء الحفظ.");
      return false;
    }

    try {
      final file = File(targetPath);
      await file.writeAsString(code);

      final FileEntity fileData = selectedFile.copyWith(
        path: targetPath,
        code: code,
        saved: true,
      );

      if (currentIndex >= 0) {
        filesList[currentIndex] = fileData;
      } else {
        filesList.add(fileData);
      }

      workspace.setSelectedFile(fileData);
      workspace.setFiles(filesList);
      terminal.addOutput("تم الحفظ في: $targetPath");
    } catch (e) {
      terminal.addOutput("خطأ أثناء الحفظ: $e");
      return false;
    }
  } else {
    try {
      await File(selectedFile.path!).writeAsString(code);
      final FileEntity fileData = selectedFile.copyWith(
        code: code,
        saved: true,
      );
      if (currentIndex >= 0) {
        filesList[currentIndex] = fileData;
      }
      workspace.setFiles(filesList);
    } catch (e) {
      terminal.addOutput("خطأ أثناء الحفظ: $e");
      return false;
    }
  }

  if (!context.mounted) return false;
  await saveFilesLocal(context);
  return true;
}

Future<void> saveFilesLocal([
  BuildContext? context,
  List<FileEntity>? files,
]) async {
  final workspace = context?.read<WorkspaceProvider>();
  final finalFiles = workspace?.files ?? files ?? [];
  await HiveHelper.saveListData<FileEntity>(kBoxOpenedFiles, finalFiles);
}
