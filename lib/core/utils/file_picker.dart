import "dart:io";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../constants.dart";
import "../extensions/strings.dart";
import "../theme/colors.dart";
import "../theme/material.dart";
import "../theme/text.dart";
import "../widgets/show_bottom_sheet.dart";
import "show_message.dart";

const _alifExtensions = [".alif", ".الف", ".aliflib"];
final _alifExtensionRegex = RegExp(r"\.(الف|alif|aliflib)$");

/// Bundles the recursive-navigation params so every re-entrant call
/// (back button, path bar, folder tap) stays in sync automatically.
class _FileManagerConfig {
  const _FileManagerConfig({
    required this.rootPath,
    required this.onFileSelected,
    required this.isWorkspace,
    required this.isSaveMode,
    this.onFolderSelected,
    this.onSave,
  });

  final String rootPath;
  final void Function(String) onFileSelected;
  final bool isWorkspace;
  final bool isSaveMode;
  final void Function(String)? onFolderSelected;
  final void Function(String fullPath)? onSave;
}

Future<void> showFileManagerModal(
  BuildContext context,
  void Function(String) onFileSelected, {
  String rootPath = "/",
  String? startPath,
  bool isWorkspace = false,
  void Function(String)? onFolderSelected,
  bool isSaveMode = false,
  String defaultFileName = "شفرة",
  void Function(String fullPath)? onSave,
}) {
  return _showFileManagerModal(
    context,
    startPath ?? rootPath,
    defaultFileName,
    _FileManagerConfig(
      rootPath: rootPath,
      onFileSelected: onFileSelected,
      isWorkspace: isWorkspace,
      isSaveMode: isSaveMode,
      onFolderSelected: onFolderSelected,
      onSave: onSave,
    ),
  );
}

Future<void> _showFileManagerModal(
  BuildContext context,
  String currentPath,
  String defaultFileName,
  _FileManagerConfig config,
) async {
  final directory = Directory(currentPath);

  if (!await directory.exists()) {
    if (!context.mounted) return;
    showMessage("المجلد غير موجود: $currentPath", isError: true);
    return;
  }

  final items =
      directory.listSync().where((entity) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith(".")) return false;
        if (FileSystemEntity.isDirectorySync(entity.path)) return true;

        final lowerName = name.toLowerCase();
        return _alifExtensions.any(lowerName.endsWith);
      }).toList()..sort((a, b) {
        final isDirA = FileSystemEntity.isDirectorySync(a.path);
        final isDirB = FileSystemEntity.isDirectorySync(b.path);
        if (isDirA != isDirB) return isDirA ? -1 : 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

  if (!context.mounted) return;

  final pathController = TextEditingController(
    text: currentPath.handelHomePath,
  );
  final fileNameController = TextEditingController(text: defaultFileName);

  showMyBottomSheet(
    context: context,
    header: _buildHeader(
      context,
      currentPath,
      pathController,
      fileNameController,
      config,
    ),
    child: Column(
      children: [
        SizedBox(height: kDefaultPadding * (config.isSaveMode ? 4 : 2)),
        Expanded(
          child: items.isEmpty
              ? Text(
                  "لا يوجد ملفات للغة ألف في هذا المجلد",
                  style: TextStyle(color: context.secondary, height: 4),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (listContext, index) => _buildItemTile(
                    context,
                    listContext,
                    items[index],
                    fileNameController,
                    config,
                  ),
                ),
        ),
      ],
    ),
  );
}

Widget _buildItemTile(
  BuildContext context,
  BuildContext listContext,
  FileSystemEntity entity,
  TextEditingController fileNameController,
  _FileManagerConfig config,
) {
  final isDir = FileSystemEntity.isDirectorySync(entity.path);
  final name = entity.path.split(Platform.pathSeparator).last;

  return ListTile(
    leading: Icon(
      isDir ? LucideIcons.folder : LucideIcons.fileCode,
      color: isDir ? const Color(0xFFDAB744) : listContext.foreground,
    ),
    title: Text(name, style: TextStyle(color: listContext.foreground)),
    subtitle: Text(
      isDir
          ? entity.path.getSafeDirCount
          : "الحجم ${File(entity.path).statSync().size.formatFileSize}",
      style: TextStyle(color: listContext.secondary),
    ),
    trailing: isDir && config.onFolderSelected != null && !config.isWorkspace
        ? IconButton(
            icon: Icon(LucideIcons.plus, color: listContext.secondary),
            onPressed: () {
              if (!listContext.mounted) return;
              config.onFolderSelected!(entity.path);
              Navigator.pop(listContext);
            },
          )
        : null,
    onTap: () {
      if (!listContext.mounted) return;

      if (isDir) {
        Navigator.pop(listContext);
        _showFileManagerModal(
          context,
          entity.path,
          fileNameController.text,
          config,
        );
        return;
      }

      if (config.isSaveMode) {
        fileNameController.text = name.replaceAll(_alifExtensionRegex, "");
      } else {
        Navigator.pop(listContext);
        config.onFileSelected(entity.path);
      }
    },
  );
}

Widget _buildHeader(
  BuildContext context,
  String currentPath,
  TextEditingController pathController,
  TextEditingController fileNameController,
  _FileManagerConfig config,
) {
  final canGoBack = currentPath != config.rootPath && currentPath != "/";
  final parentPath = Directory(currentPath).parent.path;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        spacing: kSmallPadding,
        children: [
          if (canGoBack)
            MyMaterial(
              theme: MyMaterialTheme.border,
              padding: EdgeInsets.zero,
              child: IconButton(
                icon: Icon(LucideIcons.chevronLeft, color: context.secondary),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showFileManagerModal(
                    context,
                    parentPath,
                    fileNameController.text,
                    config,
                  );
                },
              ),
            ),
          Expanded(
            child: MyMaterial(
              theme: MyMaterialTheme.border,
              padding: const EdgeInsets.all(kSmallPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.folderSearch,
                    size: 18,
                    color: context.secondary,
                  ),
                  Expanded(
                    child: TextField(
                      controller: pathController,
                      style: ThemeText.mid,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: "ادخل المسار هنا...",
                        hintStyle: TextStyle(color: context.secondary),
                      ),
                      onSubmitted: (value) => _onPathSubmitted(
                        context,
                        value,
                        currentPath,
                        pathController,
                        fileNameController,
                        config,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      if (config.isSaveMode)
        _buildSaveRow(context, currentPath, fileNameController, config),
    ],
  );
}

void _onPathSubmitted(
  BuildContext context,
  String value,
  String currentPath,
  TextEditingController pathController,
  TextEditingController fileNameController,
  _FileManagerConfig config,
) {
  if (value.trim().isEmpty) return;

  void resetPathField() => pathController.text = currentPath.handelHomePath;

  try {
    final inputDir = Directory(value.handelHomePath);
    if (!inputDir.existsSync()) {
      showMessage("المسار غير موجود", isError: true);
      resetPathField();
      return;
    }

    final resolvedNew = inputDir.resolveSymbolicLinksSync();
    final resolvedRoot = Directory(config.rootPath).resolveSymbolicLinksSync();

    final isAllowed =
        resolvedNew == resolvedRoot ||
        resolvedNew.startsWith(resolvedRoot + Platform.pathSeparator);

    if (!isAllowed) {
      showMessage("غير مسموح بالخروج عن المسار الأساسي", isError: true);
      resetPathField();
      return;
    }

    if (!context.mounted) return;
    Navigator.pop(context);
    _showFileManagerModal(
      context,
      resolvedNew,
      fileNameController.text,
      config,
    );
  } catch (_) {
    showMessage("مسار غير صالح", isError: true);
    resetPathField();
  }
}

Widget _buildSaveRow(
  BuildContext context,
  String currentPath,
  TextEditingController fileNameController,
  _FileManagerConfig config,
) {
  return Padding(
    padding: const EdgeInsets.only(top: kSmallPadding),
    child: Row(
      spacing: kSmallPadding,
      children: [
        Expanded(
          child: MyMaterial(
            theme: MyMaterialTheme.border,
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kSmallPadding,
            ),
            child: TextField(
              controller: fileNameController,
              style: ThemeText.mid,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: "اسم الملف...",
                hintStyle: TextStyle(color: context.secondary),
                suffixText: ".الف",
              ),
            ),
          ),
        ),
        MyMaterial(
          theme: MyMaterialTheme.border,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: Icon(LucideIcons.save, color: context.secondary),
            onPressed: () {
              final name = fileNameController.text.trim();
              if (name.isEmpty) {
                showMessage("يجب إدخال اسم للملف", isError: true);
                return;
              }
              final cleanName = name.replaceAll(_alifExtensionRegex, "");
              final fullPath =
                  "$currentPath${Platform.pathSeparator}$cleanName.الف";

              Navigator.pop(context);
              if (config.onSave != null) {
                config.onSave!(fullPath);
              } else {
                config.onFileSelected(fullPath);
              }
            },
          ),
        ),
      ],
    ),
  );
}
