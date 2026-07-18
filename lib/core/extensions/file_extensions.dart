import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/file_model.dart";
import "../providers/workspace_provider.dart";

extension FileExtensions on int {
  FileEntity getFileOrLast({BuildContext? context, List<FileEntity>? files}) {
    final finalFiles =
        files ?? context?.read<WorkspaceProvider>().files ?? <FileEntity>[];

    final index = finalFiles.indexWhere((file) => file.id == this);
    return finalFiles[index == -1 ? finalFiles.length - 1 : index];
  }

  int getFileIndexOrLast({
    required Map<int, int> indexes,
    required List<FileEntity> files,
  }) {
    if (files.isEmpty) return -1;

    return indexes[this] ?? files.length - 1;
  }
}
