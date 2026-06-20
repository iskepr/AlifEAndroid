import "dart:convert";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../constants.dart";
import "../../features/editor/models/code_controller.dart";
import "../models/data_typs.dart";
import "../services/files/open_file.dart";
import "../services/files/save_file.dart";
import "../utils/show_message.dart";
import "settings_provider.dart";

class WorkspaceProvider extends ChangeNotifier {
  final SettingsProvider _settings;

  SharedPreferences? _prefs;
  late final CodeController codeController;
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
    codeControllerFocus = FocusNode();
    codeControllerFocus.addListener(_onFocusChange);
    findController = FindController(codeController);
    undoController = UndoRedoController();
    _selectedFile = FileEntity.empty();
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    lastFile = _prefs?.getInt(kKeyLastFile) ?? 0;
    workspacePath = _prefs?.getString(kKeyWorkspacePath);
    notifyListeners();
  }

  void setLastFile(int value) {
    lastFile = value;
    _prefs?.setInt(kKeyLastFile, value);
    notifyListeners();
  }

  void setWorkspacePath(String? path) async {
    workspacePath = path;
    notifyListeners();
    if (path != null) {
      _prefs?.setString(kKeyWorkspacePath, path);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    findController.dispose();
    undoController.dispose();
    codeControllerFocus.dispose();
    super.dispose();
  }

  void addFile(FileEntity file) async {
    files.add(file);
    _prefs?.setString(kKeyOpenedFiles, jsonEncode(files));
    notifyListeners();
  }

  void setFiles(List<FileEntity> files) {
    this.files = files;
    notifyListeners();
  }

  void updateFile(
    BuildContext context,
    int id,
    FileAction type, {
    String? newName,
  }) async {
    if (id < 0 || id >= files.length) return;
    var file = files[id];

    if (type == FileAction.rename && newName?.trim().isNotEmpty == true) {
      final String? newPath = file.path != null
          ? "${File(file.path!).parent.path}/${newName!.trim()}"
          : null;
      if (newPath != null && await File(file.path!).exists()) {
        try {
          await File(file.path!).rename(newPath);
        } catch (_) {
          await File(file.path!).copy(newPath);
          await File(file.path!).delete();
        }
        file = file.copyWith(path: newPath);
      }
      files[id] = file.copyWith(name: newName!.trim());
      if (_selectedFile.id == id) setSelectedFile(files[id]);
      if (context.mounted) openFile(id, context);
    } else if (type == FileAction.delete || type == FileAction.close) {
      final fileTarget = files[id];

      if (type == FileAction.delete && fileTarget.path?.isNotEmpty == true) {
        try {
          final f = File(fileTarget.path!).absolute;
          if (f.existsSync()) f.deleteSync(recursive: true);
        } catch (e) {
          debugPrint("حدث خطاء في حذف الملف: $e");
          showMessage(
            "فشل حذف الملف، تأكد من الصلاحيات أو أن الملف غير مستخدم",
            isError: true,
          );
          return;
        }
      }

      final removed = files.removeAt(id);
      if (_selectedFile.id == removed.id) _selectedFile = FileEntity.empty();

      if (files.isNotEmpty) {
        openFile(id >= files.length ? files.length - 1 : id, context);
      } else {
        files.add(FileEntity.empty());
        openFile(0, context);
      }
    } else if (type == FileAction.toggleReadOnly) {
      files[id] = file.copyWith(readOnly: !file.readOnly);
      if (_selectedFile.id == files[id].id) _selectedFile = files[id];
      codeController.readOnly = files[id].readOnly;
    }

    if (context.mounted) saveFilesLocal(context);
    notifyListeners();
  }

  void setSelectedFile(FileEntity file) {
    if (_selectedFile.id != -1) {
      final currentIndex = files.indexWhere((f) => f.id == _selectedFile.id);
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

    Future.microtask(() {
      final int start = file.cursor[0].clamp(0, codeController.text.length);
      final int end = file.cursor[1].clamp(0, codeController.text.length);
      codeController.selection = TextSelection(
        baseOffset: start,
        extentOffset: end,
      );
    });
    notifyListeners();
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
      final index = files.indexWhere((file) => file.id == _selectedFile.id);
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
    if (_settings.get(AppSetting.customKeyboard)) return;
    if (isKeyboardEnabled != codeControllerFocus.hasFocus) {
      isKeyboardEnabled = codeControllerFocus.hasFocus;
      if (isKeyboardEnabled) {
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      }
      notifyListeners();
    }
  }

  void toggleKeyboard({bool? enable}) {
    if (_settings.get(AppSetting.customKeyboard)) return;
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
}
