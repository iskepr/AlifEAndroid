import "dart:async";
import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/providers/settings_provider.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/services/files/save_file.dart";
import "../theme/alif_dark_theme.dart";
import "../theme/alif_lang/alif.dart";
import "search_view.dart";

class IDEView extends StatefulWidget {
  const IDEView({super.key});

  @override
  State<IDEView> createState() => _IDEViewState();
}

class _IDEViewState extends State<IDEView> {
  WorkspaceProvider? workspace;
  SettingsProvider? settings;

  LspStdioConfig? _lspConfig;
  bool _lspInitializing = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      workspace = context.read<WorkspaceProvider>();
      settings = context.read<SettingsProvider>();

      workspace!.codeController.addListener(_onCodeChanged);

      if (Platform.isAndroid) {
        // _checkAndInitLsp();
        settings!.addListener(_checkAndInitLsp);
      }
    });
  }

  void _onCodeChanged() {
    if (workspace == null || settings == null) return;

    if (workspace!.selectedFile.code != workspace!.codeController.text) {
      workspace!.editCode(
        workspace!.codeController.text,
        settings!.get(AppSetting.autoSave),
        markDirty: true,
      );

      if (settings!.get(AppSetting.autoSave)) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 500), () async {
          if (!mounted) return;

          if (workspace!.selectedFile.path?.isNotEmpty ?? false) {
            await saveFileToStorage(context);
          } else {
            await saveFilesLocal(context);
          }
        });
      }
    }
  }

  bool _isScrolling = false;

  @override
  Widget build(BuildContext context) {
    final provReadOnly = context.read<WorkspaceProvider>();
    final settings = context.watch<SettingsProvider>();

    return Listener(
      onPointerDown: (event) => _isScrolling = false,
      onPointerMove: (event) {
        if (event.delta.distance > 2.0) _isScrolling = true;
      },
      onPointerUp: (event) {
        if (!_isScrolling) {
          if (settings.get(AppSetting.customKeyboard)) {
            context.read<WorkspaceProvider>().toggleKeyboard(enable: true);
          }
        }
      },

      child: Selector<WorkspaceProvider, String?>(
        selector: (_, prov) => prov.selectedFile.path,
        builder: (context, filePath, child) {
          return CodeForge(
            // init
            controller: provReadOnly.codeController,
            undoController: provReadOnly.undoController,
            focusNode: provReadOnly.codeControllerFocus,
            language: alif,
            filePath: filePath,
            keyboardType: settings.get(AppSetting.customKeyboard)
                ? TextInputType.none
                : TextInputType.multiline,
            // features
            enableFolding: settings.get(AppSetting.enableFolding),
            enableGuideLines: settings.get(AppSetting.enableGuideLines),
            enableLocalSuggestions: settings.get(AppSetting.enableSuggestions),
            lineWrap: settings.get(AppSetting.lineWrap),
            tabSize: settings.get(AppSetting.tabSize),
            customCodeSnippets: alifSnippets,
            findController: provReadOnly.findController,
            finderBuilder: (context, findController) => PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: SearchView(findController: findController),
            ),
            // styling
            editorTheme: alifDarkTheme,
            textDirection: TextDirection.rtl,
            innerPadding: const EdgeInsets.only(left: kDefaultPadding * 2),
            textStyle: TextStyle(
              fontFamily: settings.get(AppSetting.editorFont),
              fontSize: settings.get(AppSetting.fontSize),
              height: Platform.isAndroid ? 1.4 : null,
            ),
            gutterStyle: Platform.isAndroid
                ? GutterStyle(
                    lineNumberStyle: TextStyle(
                      fontSize: settings.get(AppSetting.fontSize) * 0.95,
                      fontFamily: settings.get(AppSetting.editorFont),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _checkAndInitLsp() {
    if (_lspConfig == null && !_lspInitializing) {
      _lspInitializing = true;
      _initAlifLsp();
    }
  }

  Future<void> _initAlifLsp() async {
    try {
      final currentWorkspace =
          workspace?.workspacePath ?? Directory.current.path;
      final alifDir = File(settings!.alifBinPath).parent.path;
      const String executableName = "alif_lsp";

      final executablePath = path.join(alifDir, executableName);

      if (Platform.isAndroid) {
        await Process.run("chmod", ["+x", executablePath]);
      }

      final env = <String, String>{};
      if (Platform.isAndroid) env["LD_LIBRARY_PATH"] = alifDir;

      _lspConfig = await LspStdioConfig.start(
        executable: executablePath,
        args: [],
        workspacePath: currentWorkspace,
        languageId: "alif",
        environment: env,
      );

      if (workspace != null) {
        workspace!.codeController.lspConfig = _lspConfig;
        if (workspace!.selectedFile.path != null) {
          workspace!.codeController.openedFile = workspace!.selectedFile.path;
        }
      }
      debugPrint("Alif LSP Initialized at: $executablePath");
    } catch (e) {
      debugPrint("LSP Initialization Error: $e");
    } finally {
      _lspInitializing = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    settings?.removeListener(_checkAndInitLsp);
    workspace?.codeController.removeListener(_onCodeChanged);
    _lspConfig?.dispose();
    super.dispose();
  }
}
