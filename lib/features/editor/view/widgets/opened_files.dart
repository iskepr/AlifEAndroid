import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../constants.dart";
import "../../../../core/extensions/extensions.dart";
import "../../../../core/models/data_typs.dart";
import "../../../../core/providers/workspace_provider.dart";
import "../../../../core/services/files/open_file.dart";
import "../../../../core/utils/show_dialog.dart";
import "../../../../core/widgets/radio_input.dart";
import "edit_file_view.dart";

class OpenedFiles extends StatelessWidget {
  const OpenedFiles({super.key});

  Future<void> onLongPress(
    BuildContext context,
    int id,
    WorkspaceProvider data,
  ) async {
    final file = id.getFileOrLast(context: context);
    final TextEditingController controller = TextEditingController(
      text: file.name,
    );

    await showCustomDialog(
      title: l10n.editFile,
      onConfirm: () => data.updateFile(
        context,
        id,
        FileAction.rename,
        newName: controller.text,
      ),
      child: EditSheet(file: file, controller: controller),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding),
      child: Consumer<WorkspaceProvider>(
        builder: (context, workspace, child) => RadioInput(
          value: workspace.selectedFile.id,
          items: workspace.files.map((file) {
            final String suffix =
                "${file.readOnly ? "!" : ""}${!file.saved ? "*" : ""}";
            return SelectEntity(value: file.id, name: "${file.name}$suffix");
          }).toList(),
          onLongPress: (id) => onLongPress(context, id, workspace),
          onChanged: (id) {
            if (id is int) openFile(id, context);
          },
        ),
      ),
    );
  }
}
