import "dart:async";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../constants.dart";
import "../../features/editor/models/code_controller.dart";
import "../extensions/extensions.dart";
import "../helpers/hive_helper.dart";
import "../models/data_typs.dart";
import "../services/files/external_file_watcher.dart";
import "../services/files/open_file.dart";
import "../services/files/save_file.dart";
import "../utils/show_message.dart";
import "settings_provider.dart";

class WorkspaceProvider extends ChangeNotifier {
  late final Future<void> initFuture;

  final SettingsProvider _settings;

  late final CodeController codeController;
  StreamSubscription<FileSystemEvent>? _externalFileWatcher;
  late final FindController findController;
  late final UndoRedoController undoController;
  late final FocusNode codeControllerFocus;

  List<FileEntity> files = [];
  late FileEntity _selectedFile;
  FileEntity get selectedFile => _selectedFile;

  String? workspacePath;
  int lastFile = 0;

  WorkspaceProvider(this._settings) {
    codeController = CodeController();
    codeController.tabSize = codeController.detectIndentation();
    codeControllerFocus = FocusNode();
    codeControllerFocus.addListener(_onFocusChange);
    findController = FindController(codeController);
    undoController = UndoRedoController();
    _selectedFile = FileEntity.empty();
    _settings.addListener(_handleSettingsChanged);
    initFuture = _init();
  }

  Future<void> _init() async {
    lastFile = HiveHelper.getData<int>(kBoxSettings, kKeyLastFile) ?? 0;
    workspacePath = HiveHelper.getData<String>(kBoxSettings, kKeyWorkspacePath);
    notifyListeners();
  }

  final Map<int, int> _fileIndexes = {};
  void _updateFileIndexes() {
    _fileIndexes
      ..clear()
      ..addEntries(
        files.asMap().entries.map(
          (entry) => MapEntry(entry.value.id, entry.key),
        ),
      );
  }

  void setFiles(List<FileEntity> files) {
    this.files = List.of(files);
    _updateFileIndexes();
    notifyListeners();
  }

  void setLastFile(int value) {
    lastFile = value;
    HiveHelper.saveData<int>(kBoxSettings, key: kKeyLastFile, value);
    notifyListeners();
  }

  Future<void> setWorkspacePath(String? path) async {
    workspacePath = path;
    notifyListeners();
    if (path != null) {
      HiveHelper.saveData(kBoxSettings, key: kKeyWorkspacePath, path);
    }
  }

  void addFile(FileEntity file) {
    files.add(file);
    _fileIndexes[file.id] = files.length - 1;
    saveFilesLocal(null, files);
    notifyListeners();
  }

  Future<void> updateFile(
    BuildContext context,
    int id,
    FileAction type, {
    String? newName,
  }) async {
    final index = id.getFileIndexOrLast(indexes: _fileIndexes, files: files);
    final thisFile = files[index];

    switch (type) {
      case FileAction.rename:
        if (newName == null || newName.isEmpty) break;
        if (thisFile.path != null && await thisFile.file!.exists()) {
          final newPath = "${thisFile.parentPath}/$newName";
          try {
            await thisFile.file!.rename(newPath);
          } catch (_) {
            debugPrint("فشل في تغير اسم الملف");
            await thisFile.file!.copy(newPath);
            await thisFile.file!.delete();
          }

          files[index] = thisFile.copyWith(path: newPath);
        }
        if (_selectedFile.id == thisFile.id) setSelectedFile(files[index]);
        if (context.mounted) openFile(id, context);
        break;
      case FileAction.delete:
        if (thisFile.path != null && await thisFile.file!.exists()) {
          try {
            await thisFile.file!.delete();
          } catch (e) {
            debugPrint("حدث خطاء في حذف الملف: $e");
            showMessage(
              "فشل حذف الملف، تأكد من الصلاحيات أو أن الملف غير مستخدم",
              isError: true,
            );
            break;
          }
        }

        files.removeAt(index);
        _updateFileIndexes();
        if (context.mounted) openFile(-1, context);
        break;
      case FileAction.close:
        files.removeAt(index);
        _updateFileIndexes();
        if (context.mounted) openFile(-1, context);
        break;
      case FileAction.toggleReadOnly:
        final updatedFile = thisFile.copyWith(readOnly: !thisFile.readOnly);
        files[index] = updatedFile;
        if (_selectedFile.id == updatedFile.id) _selectedFile = updatedFile;
        codeController.readOnly = updatedFile.readOnly;
        break;
    }

    if (context.mounted) saveFilesLocal(context);
    notifyListeners();
  }

  void setSelectedFile(FileEntity file) {
    if (_selectedFile.id != -1) {
      final currentIndex = _selectedFile.id.getFileIndexOrLast(
        indexes: _fileIndexes,
        files: files,
      );
      if (currentIndex != -1) {
        files[currentIndex] = files[currentIndex].copyWith(
          cursor: [
            codeController.selection.start,
            codeController.selection.end,
          ],
        );
      }
    }

    _selectedFile = file;
    if (codeController.text != file.code) codeController.text = file.code;
    codeController.readOnly = file.readOnly;

    Future.microtask(
      () => codeController.selection = TextSelection(
        baseOffset: file.cursor[0].clamp(0, file.code.length),
        extentOffset: file.cursor[1].clamp(0, file.code.length),
      ),
    );

    _startWatchingSelectedFile(file);
    notifyListeners();
  }

  Future<void> _startWatchingSelectedFile(FileEntity file) async {
    if (!_settings.get(AppSetting.autoSave) ||
        file.path == null ||
        file.path!.isEmpty) {
      await _externalFileWatcher?.cancel();
      _externalFileWatcher = null;
      return;
    }

    await _externalFileWatcher?.cancel();
    final fileToWatch = File(file.path!);
    if (!await fileToWatch.exists()) {
      _externalFileWatcher = null;
      return;
    }

    _externalFileWatcher = fileToWatch.watch().listen((event) async {
      if (!hasListeners) return;

      final updatedFile = await ExternalFileWatcher.applyEvent(
        currentFile: file,
        eventType: event.type,
        autoSaveEnabled: _settings.get(AppSetting.autoSave),
      );

      final index = file.id.getFileIndexOrLast(
        indexes: _fileIndexes,
        files: files,
      );
      if (index >= 0) {
        files[index] = updatedFile;
        if (selectedFile.id == file.id) {
          _selectedFile = updatedFile;
          if (codeController.text != updatedFile.code) {
            codeController.text = updatedFile.code;
          }
        }
        notifyListeners();
      }
    });
  }

  void _handleSettingsChanged() {
    final nextTabSize = _settings.get<int>(AppSetting.tabSize);
    if (codeController.tabSize == nextTabSize) return;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => codeController.reindentDocument(newTabSize: nextTabSize),
    );
  }

  void editCode(
    String newCode,
    bool autoSaveEnabled, {
    TextSelection? selection,
    bool markDirty = false,
  }) {
    if (codeController.text != newCode) codeController.text = newCode;
    if (selection != null) codeController.selection = selection;

    if (markDirty) {
      _selectedFile = _selectedFile.copyWith(
        code: newCode,
        saved: autoSaveEnabled,
      );
      final index = _selectedFile.id.getFileIndexOrLast(
        indexes: _fileIndexes,
        files: files,
      );
      if (index >= 0) {
        files[index] = files[index].copyWith(
          code: newCode,
          saved: autoSaveEnabled,
        );
      }
    }
    notifyListeners();
  }

  bool isKeyboardEnabled = false;
  void _onFocusChange() {
    if (!_settings.get(AppSetting.customKeyboard)) return;
    if (isKeyboardEnabled != codeControllerFocus.hasFocus) {
      isKeyboardEnabled = codeControllerFocus.hasFocus;
      if (isKeyboardEnabled) {
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      }
      notifyListeners();
    }
  }

  void toggleKeyboard({bool? enable}) {
    if (!_settings.get(AppSetting.customKeyboard)) return;
    isKeyboardEnabled = enable ?? !isKeyboardEnabled;
    if (isKeyboardEnabled) {
      SystemChannels.textInput.invokeMethod("TextInput.hide");
      if (!codeControllerFocus.hasFocus) {
        codeControllerFocus.requestFocus();
      }
    }
    notifyListeners();
  }

  void toggleSearch() {
    findController.isActive = !findController.isActive;
    if (findController.isActive) {
      if (!codeController.selection.isCollapsed) {
        final selectedText = codeController.text.substring(
          codeController.selection.start,
          codeController.selection.end,
        );

        findController.findInputController.text = selectedText;
      }

      findController.findInputFocusNode.unfocus();
    } else {
      findController.clear();
      codeControllerFocus.requestFocus();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.removeListener(_handleSettingsChanged);
    _externalFileWatcher?.cancel();
    codeController.dispose();
    findController.dispose();
    undoController.dispose();
    codeControllerFocus.dispose();
    super.dispose();
  }
}
