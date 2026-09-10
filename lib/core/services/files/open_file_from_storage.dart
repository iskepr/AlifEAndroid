import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../providers/workspace_provider.dart";
import "../../utils/file_picker.dart";
import "../../utils/show_message.dart";
import "create_file.dart";
import "open_file.dart";

Future<void> openFileFromStorage(
  BuildContext context, {
  String rootPath = "/",
  String? startPath,
  bool isWorkspace = false,
}) async {
  try {
    final workspace = context.read<WorkspaceProvider>();

    showFileManagerModal(
      context,
      (selectedPath) async {
        final file = File(selectedPath);

        final String code = await file.readAsString();
        final String fileName = selectedPath.split(Platform.pathSeparator).last;

        final int existingIndex = workspace.files.indexWhere(
          (f) => f.path == selectedPath,
        );

        if (!context.mounted) return;
        if (existingIndex >= 0) {
          openFile(existingIndex, context);
        } else {
          createFile(context, name: fileName, path: selectedPath, code: code);
        }
      },
      rootPath: rootPath,
      startPath: startPath,
      isWorkspace: isWorkspace,
      onFolderSelected: (folderPath) => workspace.setWorkspacePath(folderPath),
    );
  } catch (e) {
    showMessage("فشل في فتح الملف بسبب ${l10n.error} في القراءة");
  }
}
