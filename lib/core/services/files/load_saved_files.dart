import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../helpers/hive_helper.dart";
import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";
import "create_file.dart";
import "open_file.dart";

Future<void> loadFilesFromStorage(BuildContext context) async {
  final workspace = context.read<WorkspaceProvider>();
  final lastFile = HiveHelper.getData<int>(kBoxSettings, kKeyLastFile) ?? 0;

  final savedFiles = HiveHelper.getListData<FileEntity>(kBoxOpenedFiles);
  if (savedFiles.isNotEmpty) workspace.files = savedFiles;

  if (!context.mounted) return;
  if (workspace.files.isNotEmpty) {
    final selectedId = lastFile >= 0 && lastFile < workspace.files.length
        ? lastFile
        : 0;
    await openFile(selectedId, context);
  } else {
    const fileName = "لعبة_اكس_او.الف";
    final gameCode = await rootBundle.loadString("assets/examples/$fileName");
    if (!context.mounted) return;
    createFile(context, name: fileName, code: gameCode);
  }
}
