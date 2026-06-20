import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../terminal/provider/terminal_provider.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/theme/colors.dart";
import "../../../terminal/functions/run_command.dart";
import "../../../terminal/view/terminal_view.dart";
import "key_button.dart";

class ShortcutsView extends StatefulWidget {
  const ShortcutsView({super.key});

  @override
  State<ShortcutsView> createState() => _ShortcutsViewState();
}

class _ShortcutsViewState extends State<ShortcutsView> {
  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkspaceProvider>().codeController.addListener(_update);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.read<WorkspaceProvider>();

    final isSearchActive = context.select<WorkspaceProvider, bool>(
      (p) => p.findController.isActive,
    );
    final isReadOnly = context.select<WorkspaceProvider, bool>(
      (p) => p.codeController.readOnly,
    );
    final canUndo = context.select<WorkspaceProvider, bool>(
      (p) => p.undoController.canUndo,
    );
    final canRedo = context.select<WorkspaceProvider, bool>(
      (p) => p.undoController.canRedo,
    );
    final isRunning = context.select<TerminalProvider, bool>(
      (p) => p.runningProcess?.exitCode == null && p.runningProcess != null,
    );

    final bool hasSelection =
        workspace.codeController.selection.start !=
        workspace.codeController.selection.end;

    const double iconSize = 17;

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
        child: Row(
          children: [
            // زرار التشغيل
            KeyButton(
              onPressed: () {
                final terminal = context.read<TerminalProvider>();
                terminal.clearOutput();
                runCommand(context, kAlifBin);
                showTerminalView(context);
              },
              child: Icon(
                isRunning ? LucideIcons.square : LucideIcons.play,
                size: iconSize,
                color: isRunning ? Colors.red : context.foreground,
              ),
            ),

            KeyButton(
              onPressed: () => workspace.toggleSearch(),
              child: isSearchActive ? LucideIcons.x : LucideIcons.search,
            ),

            // Undo / Redo
            KeyButton(
              onPressed: () => workspace.undoController.undo(),
              disabled: !canUndo,
              child: LucideIcons.undo2,
            ),
            KeyButton(
              onPressed: () => workspace.undoController.redo(),
              disabled: !canRedo,
              child: LucideIcons.redo2,
            ),

            // عمليات السطور
            KeyButton(
              onPressed: () => workspace.codeController.moveLineUp(),
              child: LucideIcons.arrowUp,
            ),
            KeyButton(
              onPressed: () => workspace.codeController.moveLineDown(),
              child: LucideIcons.arrowDown,
            ),
            KeyButton(
              onPressed: () => workspace.codeController.duplicateLine(),
              child: LucideIcons.layers2,
            ),

            // Clipboard
            KeyButton(
              onPressed: () => workspace.codeController.paste(),
              child: LucideIcons.clipboard,
            ),

            // أزرار التحديد
            if (hasSelection) ...[
              KeyButton(
                onPressed: () => workspace.codeController.copy(),
                child: LucideIcons.copy,
              ),
              if (!isReadOnly)
                KeyButton(
                  onPressed: () => workspace.codeController.cut(),
                  child: LucideIcons.scissors,
                ),
              KeyButton(
                onPressed: () => workspace.codeController.selectAll(),
                child: LucideIcons.squareDashed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<WorkspaceProvider>().codeController.removeListener(_update);
    } catch (_) {}
    super.dispose();
  }
}
