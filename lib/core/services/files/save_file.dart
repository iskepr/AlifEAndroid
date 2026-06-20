import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:file_saver/file_saver.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../constants.dart";
import "../../models/data_typs.dart";
import "../../../features/terminal/provider/terminal_provider.dart";
import "../../providers/workspace_provider.dart";

Future<bool> saveFileToStorage(
  BuildContext context, {
  bool asNew = false,
}) async {
  final workspace = context.read<WorkspaceProvider>();
  final terminal = context.read<TerminalProvider>();

  if (workspace.files.isEmpty) {
    terminal.addOutput("لا يوجد ملف مفتوح للحفظ.");
    return false;
  }

  final code = workspace.codeController.text;
  final selectedId = workspace.selectedFile.id;
  final filesList = List<FileEntity>.from(workspace.files);
  final currentIndex = filesList.indexWhere((file) => file.id == selectedId);

  if (workspace.selectedFile.path == null ||
      workspace.selectedFile.path!.isEmpty ||
      asNew) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(code));
      final path = await FileSaver.instance.saveAs(
        name: (workspace.selectedFile.name.isEmpty)
            ? "شفرة"
            : workspace.selectedFile.name.replaceAll(
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

      final FileEntity fileData = workspace.selectedFile.copyWith(
        name: path.split(Platform.pathSeparator).last,
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
      await File(workspace.selectedFile.path!).writeAsString(code);
      final FileEntity fileData = workspace.selectedFile.copyWith(
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

Future<void> saveFilesLocal(BuildContext context) async {
  final workspace = context.read<WorkspaceProvider>();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kKeyOpenedFiles, jsonEncode(workspace.files));
  workspace.setFiles(workspace.files);
}
