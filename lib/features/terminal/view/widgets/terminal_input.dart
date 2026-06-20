import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/colors.dart";
import "../../functions/run_command.dart";
import "../../provider/terminal_provider.dart";

class TerminalInput extends StatefulWidget {
  const TerminalInput({super.key});

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput> {
  final TextEditingController inputController = TextEditingController();

  void runCommandHandler(TerminalProvider data, BuildContext context) async {
    if (data.runningProcess?.exitCode == null) {
      await runCommand(context, inputController.text);
    } else {
      data.sendOutput(inputController.text);
    }
    inputController.clear();
    if (!context.mounted) return;
    FocusScope.of(context).requestFocus(data.terminalFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TerminalProvider>(
      builder: (context, data, child) => Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: data.terminalFocus,
              autofocus: true,
              controller: inputController,
              onSubmitted: (_) => runCommandHandler(data, context),
              style: TextStyle(color: context.foreground),
              decoration: InputDecoration(
                hintText: data.terminalHint,
                hintStyle: TextStyle(color: context.secondary),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => runCommandHandler(data, context),
            icon: Icon(LucideIcons.arrowRight, color: context.foreground),
          ),
        ],
      ),
    );
  }
}
