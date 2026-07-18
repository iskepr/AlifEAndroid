import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../extensions/extensions.dart";
import "../../providers/settings_provider.dart";
import "../../providers/workspace_provider.dart";
import "create_file.dart";
import "save_file.dart";

Future<void> openFile(int fileId, BuildContext context) async {
  final workspace = context.read<WorkspaceProvider>();
  final settings = context.read<SettingsProvider>();
  final files = workspace.files;

  if (files.isEmpty) {
    createFile(context);
    return;
  }

  final openedFile = fileId.getFileOrLast(files: files);

  if (workspace.selectedFile.id != -1 && !workspace.selectedFile.saved) {
    await saveFilesLocal(context);

    if (workspace.selectedFile.path?.isNotEmpty == true) {
      if (!context.mounted) return;
      await saveFileToStorage(context);
    }
  }

  workspace.setLastFile(openedFile.id);
  workspace.setSelectedFile(openedFile);

  workspace.editCode(
    openedFile.code,
    settings.get(AppSetting.autoSave),
    markDirty: false,
  );

  workspace.codeControllerFocus.requestFocus();
}
