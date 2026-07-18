import "dart:io";

import "../../models/file_model.dart";

class ExternalFileWatcher {
  static Future<FileEntity> applyEvent({
    required FileEntity currentFile,
    required int eventType,
    required bool autoSaveEnabled,
  }) async {
    if (currentFile.path == null || currentFile.path!.isEmpty) {
      return currentFile;
    }

    final file = File(currentFile.path!);

    if (eventType == FileSystemEvent.delete) {
      return currentFile.copyWith(saved: false);
    }

    if (eventType == FileSystemEvent.modify ||
        eventType == FileSystemEvent.create) {
      if (await file.exists()) {
        final contents = await file.readAsString();
        return currentFile.copyWith(code: contents, saved: autoSaveEnabled);
      }
    }

    if (eventType == FileSystemEvent.move) {
      if (await file.exists()) {
        final contents = await file.readAsString();
        return currentFile.copyWith(
          path: file.path,
          code: contents,
          saved: autoSaveEnabled,
        );
      }
    }

    return currentFile;
  }
}
