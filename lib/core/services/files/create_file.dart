import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../models/data_typs.dart";
import "../../providers/workspace_provider.dart";
import "open_file.dart";

void createFile(
  BuildContext context, {
  String name = "",
  String path = "",
  String code = "",
}) {
  final workspace = context.read<WorkspaceProvider>();
  final newId = workspace.files.isNotEmpty
      ? workspace.files.map((file) => file.id).reduce(max) + 1
      : 0;

  final fileName = "ملف_جديد_${workspace.files.length + 1}.الف";
  final FileEntity newFile = FileEntity(
    id: newId,
    tempName: name.isEmpty ? fileName : name,
    path: path.isEmpty ? null : path,
    code: code,
    saved: false,
  );
  workspace.addFile(newFile);
  openFile(newId, context);
}
