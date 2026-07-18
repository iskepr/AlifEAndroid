import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../constants.dart";
import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";
import "create_file.dart";
import "open_file.dart";

Future<void> loadFilesFromStorage(BuildContext context) async {
  final workspace = context.read<WorkspaceProvider>();
  final prefs = await SharedPreferences.getInstance();
  final savedFiles = prefs.getString(kKeyOpenedFiles);
  final lastFile = prefs.getInt(kKeyLastFile) ?? 0;

  if (savedFiles != null) {
    try {
      final decoded = jsonDecode(savedFiles);
      if (decoded is List) {
        workspace.files = decoded
            .map((file) => FileEntity.fromJson(file))
            .toList();
      }
    } catch (e) {
      debugPrint("خطأ في قراءة الملفات المخزنة: $e");
    }
  }
  if (!context.mounted) return;
  if (workspace.files.isNotEmpty) {
    final selectedIndex = lastFile >= 0 && lastFile < workspace.files.length
        ? lastFile
        : 0;
    await openFile(selectedIndex, context);
  } else {
    const fileName = "لعبة_اكس_او.الف";
    final gameCode = await rootBundle.loadString("assets/examples/$fileName");
    if (!context.mounted) return;
    createFile(context,name: fileName, code: gameCode);
  }
}
