import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../../core/services/files/load_saved_files.dart";
import "../../../core/services/premissions.dart";
import "../../../core/utils/setup_alif.dart";
import "../../../core/widgets/custom_app_bar.dart";
import "../../keyboard/view/keyboard_view.dart";
import "../../keyboard/view/widgets/shortcuts_view.dart";
import "widgets/ide_view.dart";
import "widgets/opened_files.dart";

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  Future<void> _initializeEditor() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await loadFilesFromStorage(context);
      await requestStoragePermission();
      if (!mounted) return;
      await setupAlif(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<WorkspaceProvider, bool>(
      selector: (_, prov) => prov.isKeyboardEnabled,
      builder: (context, isKeyboardEnabled, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: PopScope(
            canPop: !isKeyboardEnabled,
            onPopInvokedWithResult: (didPop, result) {
              if (isKeyboardEnabled && !didPop) {
                context.read<WorkspaceProvider>().toggleKeyboard();
              }
            },
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Background.webp"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
              child: Column(
                children: [
                  const CustomAppBar(),
                  const OpenedFiles(),
                  const Expanded(child: IDEView()),
                  _BuiltInKeyboard(isKeyboardEnabled: isKeyboardEnabled),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuiltInKeyboard extends StatelessWidget {
  final bool isKeyboardEnabled;
  const _BuiltInKeyboard({required this.isKeyboardEnabled});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: !isKeyboardEnabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ShortcutsView(),
          if (!isKeyboardEnabled)
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),

          AnimatedSize(
            duration: kAnimationDuration,
            curve: kCurveEaseInOut,
            child: isKeyboardEnabled
                ? const KeyboardView()
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
