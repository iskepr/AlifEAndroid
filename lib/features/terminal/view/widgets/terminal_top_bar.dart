import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/text.dart";
import "../../../../core/utils/show_message.dart";
import "../../functions/run_command.dart";
import "../../provider/terminal_provider.dart";

class TerminalTopBar extends StatelessWidget {
  const TerminalTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: kMediumPadding),
            Text(l10n.terminal, style: ThemeText.title),
          ],
        ),
        Consumer<TerminalProvider>(
          builder: (context, data, child) => Row(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.listX,
                  color: context.foreground,
                  size: kLargeFont,
                ),
                onPressed: data.clearOutput,
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.copy,
                  color: context.foreground,
                  size: kLargeFont,
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: data.output));
                  showMessage("تم نسخ مخرجات الطرفية بالكامل", isError: false);
                },
              ),
              IconButton(
                icon: Icon(
                  data.runningProcess?.exitCode == null
                      ? LucideIcons.play
                      : LucideIcons.square,
                  size: kLargeFont,
                  color: data.runningProcess?.exitCode == null
                      ? context.foreground
                      : Colors.red,
                ),
                onPressed: () => runCommand(context, kAlifBin),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
