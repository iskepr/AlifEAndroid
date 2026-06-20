import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";
import "../../editor/models/code_controller.dart";
import "../../editor/models/key_entity.dart";
import "../data/keyboard_provider.dart";
import "widgets/key_button.dart";

class KeyboardView extends StatefulWidget {
  const KeyboardView({super.key});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  bool isArabic = true;
  bool isCap = false;
  bool isNum = true;
  double _dragOffsetDx = 0;
  double _dragOffsetDy = 0;
  static const double _threshold = 15.0;

  @override
  Widget build(BuildContext context) {
    final isEnabled = context.select<WorkspaceProvider, bool>(
      (p) => p.isKeyboardEnabled,
    );
    if (!isEnabled) return const SizedBox.shrink();

    final workspace = context.read<WorkspaceProvider>();
    final controller = workspace.codeController;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseLayout = isArabic
        ? ShortcutsProvider.arabicLayout
        : ShortcutsProvider.englishLayout;

    final currentLayout = isNum
        ? [ShortcutsProvider.nums, ...baseLayout]
        : baseLayout;

    return Container(
      height: screenHeight * 0.32,
      padding: const EdgeInsets.symmetric(horizontal: kSmallPadding),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            ...currentLayout.asMap().entries.map((entry) {
              return Expanded(
                child: Row(
                  children: _buildKeyRow(
                    entry.key,
                    entry.value,
                    currentLayout.length,
                    controller,
                  ),
                ),
              );
            }),

            Expanded(child: _buildBottomRow(controller, workspace)),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: kDefaultPadding),
                IconButton(
                  onPressed: () => workspace.toggleKeyboard(),
                  icon: const Icon(LucideIcons.chevronDown, size: 20),
                  constraints: const BoxConstraints(maxHeight: 30, minWidth: 50),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKeyRow(
    int rowIndex,
    List<KeyEntity> row,
    int totalRows,
    dynamic controller,
  ) {
    final List<Widget> keys = row.map((item) {
      final String name = (isCap && !isArabic)
          ? item.name.toUpperCase()
          : item.name;
      final bool hasShortcut = item.insert != item.name;

      return Expanded(
        flex: 2,
        child: KeyButton(
          shortcut: hasShortcut ? item.insert : null,
          onPressed: () {
            controller.insert(context, char: name);
            if (isCap) setState(() => isCap = false);
          },
          onLongPress: hasShortcut
              ? () => controller.insert(context, shortcut: item)
              : null,
          child: name,
        ),
      );
    }).toList();

    if (rowIndex == totalRows - 1) {
      keys.insert(
        0,
        _buildSpecialKey(
          LucideIcons.delete,
          () => controller.backspace(),
          isRepeatable: true,
        ),
      );
      if (!isArabic) {
        keys.add(
          _buildSpecialKey(
            isCap ? LucideIcons.arrowUpFromLine : LucideIcons.arrowUp,
            () => setState(() => isCap = !isCap),
          ),
        );
      }
    }
    return keys;
  }

  Widget _buildSpecialKey(
    IconData icon,
    VoidCallback onPressed, {
    bool isRepeatable = false,
  }) {
    return Expanded(
      flex: 3,
      child: KeyButton(
        isRepeatable: isRepeatable,
        onPressed: onPressed,
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildBottomRow(
    CodeController controller,
    WorkspaceProvider workspace,
  ) {
    return Row(
      children: [
        _buildActionKey(
          LucideIcons.cornerDownLeft,
          () => controller.insert(context, char: "\n"),
          label: LucideIcons.arrowRightToLine,
          onLongPress: () => controller.indent(),
          flex: 2,
        ),
        _buildActionKey(
          null,
          () => controller.insert(context, char: "."),
          label: ".",
          flex: 1,
        ),

        // زرار المسافة مع تحريك المؤشر
        Expanded(
          flex: 5,
          child: KeyButton(
            onPressed: () => controller.insert(context, char: " "),
            onPanUpdate: _handleSpaceBarPan,
            onPanEnd: (_) => setState(() {
              _dragOffsetDx = 0;
              _dragOffsetDy = 0;
            }),
            child: Text(isArabic ? "العربية" : "English"),
          ),
        ),

        _buildActionKey(
          LucideIcons.globe,
          () => setState(() => isArabic = !isArabic),
          flex: 1,
        ),
        _buildActionKey(
          null,
          () => setState(() => isNum = !isNum),
          label: isNum ? "ABC" : "?123",
          flex: 2,
        ),
      ],
    );
  }

  Widget _buildActionKey(
    IconData? icon,
    VoidCallback onPressed, {
    VoidCallback? onLongPress,
    dynamic label,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: KeyButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        shortcut: icon == null ? null : label,
        child: icon != null ? Icon(icon, size: 20) : Text(label ?? ""),
      ),
    );
  }

  void _handleSpaceBarPan(DragUpdateDetails details) {
    _dragOffsetDx += details.delta.dx;
    _dragOffsetDy += details.delta.dy;

    final shortcuts = context.read<ShortcutsProvider>();

    if (_dragOffsetDx.abs() > _threshold) {
      shortcuts.moveCursorHorizontal(
        context.read<WorkspaceProvider>().codeController,
        _dragOffsetDx > 0 ? 1 : -1,
      );
      _dragOffsetDx = 0;
    }
    if (_dragOffsetDy.abs() > _threshold) {
      shortcuts.moveCursorVertical(
        context.read<WorkspaceProvider>().codeController,
        _dragOffsetDy > 0 ? 1 : -1,
      );
      _dragOffsetDy = 0;
    }
  }
}
