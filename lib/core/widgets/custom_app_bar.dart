import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../constants.dart";
import "../../features/settings/view/settings_view.dart";
import "../../features/terminal/view/terminal_view.dart";
import "../providers/workspace_provider.dart";
import "../services/files/create_file.dart";
import "../services/files/open_file_from_storage.dart";
import "../services/files/save_file.dart";
import "../theme/colors.dart";
import "../theme/text.dart";
import "show_bottom_sheet.dart";

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kMediumPadding,
              right: kMediumPadding,
              left: kMediumPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showMyBottomSheet(
                      context: context,
                      isScrolable: true,
                      child: const SettingsView(),
                    );
                  },
                  child: Text(l10n.title, style: ThemeText.title),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => createFile(context),
                      icon: Icon(
                        LucideIcons.plus,
                        size: 20,
                        color: context.text,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.terminal,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => showTerminalView(context),
                    ),
                    if (workspace.workspacePath != null)
                      IconButton(
                        onPressed: () => openFileFromStorage(
                          context,
                          rootPath: workspace.workspacePath!,
                          startPath: workspace.workspacePath,
                          isWorkspace: true,
                        ),
                        icon: Icon(
                          LucideIcons.files,
                          size: 20,
                          color: context.text,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.save,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () => saveFileToStorage(context),
                      onLongPress: () =>
                          saveFileToStorage(context, asNew: true),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.folderOpen,
                        color: context.foreground,
                        size: kLargeFont,
                      ),
                      onPressed: () =>
                          openFileFromStorage(context, rootPath: kHomeDir),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
