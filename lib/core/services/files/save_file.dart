import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:file_saver/file_saver.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../../features/terminal/provider/terminal_provider.dart";
import "../../helpers/hive_helper.dart";
import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";

Future<bool> saveFileToStorage(
  BuildContext context, {
  bool asNew = false,
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
    try {
      final bytes = Uint8List.fromList(utf8.encode(code));
      final path = await FileSaver.instance.saveAs(
        name: (selectedFile.name.isEmpty)
            ? "شفرة"
            : selectedFile.name.replaceAll(
                RegExp(r"\.(الف|alif|aliflib)$"),
                "",
              ),
        bytes: bytes,
        fileExtension: "الف",
        mimeType: MimeType.other,
      );

      if (path == null || path.isEmpty) {
        terminal.addOutput("تم إلغاء الحفظ.");
        return false;
      }

      final FileEntity fileData = selectedFile.copyWith(
        path: path,
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
      terminal.addOutput("تم الحفظ في: $path");
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
  final finalFilse = workspace?.files ?? files ?? [];
  await HiveHelper.saveListData<FileEntity>(kBoxOpenedFiles, finalFilse);
}
