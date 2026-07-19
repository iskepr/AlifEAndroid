import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
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

  @override
  void initState() {
    super.initState();
    inputController.addListener(
      () => context.read<TerminalProvider>().updateSuggestions(
        inputController.text,
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void _applySuggestion(String text, TerminalProvider provider) {
    inputController.text = text;
    inputController.selection = TextSelection.collapsed(offset: text.length);
    provider.clearSuggestions();
    provider.terminalFocus.requestFocus();
  }

  void runCommandHandler(TerminalProvider data, BuildContext context) async {
    if (data.suggestions.isNotEmpty) {
      _applySuggestion(data.suggestions.first, data);
      return;
    }

    final text = inputController.text;
    await data.saveHistory(text);

    if (data.runningProcess?.exitCode == null) {
      if (context.mounted) await runCommand(context, text);
    } else {
      data.sendOutput(text);
    }

    inputController.clear();
    if (context.mounted) {
      FocusScope.of(context).requestFocus(data.terminalFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final terminal = context.read<TerminalProvider>();

    final hint = context.select<TerminalProvider, String>(
      (p) => p.terminalHint,
    );
    final suggestions = context.select<TerminalProvider, List<String>>(
      (p) => p.suggestions,
    );
    context.select<TerminalProvider, bool>(
      (p) => p.runningProcess?.exitCode == null,
    );

    final firstSuggestion = suggestions.isNotEmpty ? suggestions.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.secondary.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestions
                  .map(
                    (suggestion) => InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _applySuggestion(suggestion, terminal),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: Text(
                          suggestion,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: context.foreground),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  if (firstSuggestion != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        firstSuggestion,
                        style: TextStyle(
                          color: context.secondary.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  TextField(
                    focusNode: terminal.terminalFocus,
                    autofocus: true,
                    controller: inputController,
                    onSubmitted: (_) => runCommandHandler(terminal, context),
                    style: TextStyle(
                      color: context.foreground,
                      fontFamily: kTerminalFont,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: context.secondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => runCommandHandler(terminal, context),
              icon: Icon(LucideIcons.arrowRight, color: context.foreground),
            ),
          ],
        ),
      ],
    );
  }
}
