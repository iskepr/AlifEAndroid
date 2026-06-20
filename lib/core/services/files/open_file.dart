import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/settings_provider.dart";
import "../../providers/workspace_provider.dart";
import "save_file.dart";

Future<void> openFile(int fileID, BuildContext context) async {
  final workspace = context.read<WorkspaceProvider>();
  final settings = context.read<SettingsProvider>();
  final files = workspace.files;
  if (fileID < 0 || fileID >= files.length) return;

  if (workspace.selectedFile.id != -1 && !workspace.selectedFile.saved) {
    await saveFilesLocal(context);
    if (workspace.selectedFile.path != null &&
        workspace.selectedFile.path!.isNotEmpty) {
      if (!context.mounted) return;
      await saveFileToStorage(context);
    }
  }

  workspace.setLastFile(fileID);

  final openedFile = files[fileID];
  workspace.setSelectedFile(openedFile.copyWith(id: fileID));
  workspace.editCode(
    openedFile.code,
    settings.get(AppSetting.autoSave),
    markDirty: false,
  );
  workspace.codeControllerFocus.requestFocus();
}
