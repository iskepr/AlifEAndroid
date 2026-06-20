import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../../constants.dart";
import "../../../../core/models/data_typs.dart";
import "../../../../core/utils/show_message.dart";
import "../../provider/terminal_provider.dart";

class TerminalOutputs extends StatelessWidget {
  const TerminalOutputs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TerminalProvider>(
      builder: (context, data, child) {
        final Map<int, List<TerminalLine>> sessionsMap = {};
        for (var line in data.outputLines) {
          sessionsMap.putIfAbsent(line.sessionId, () => []).add(line);
        }

        final sessionIds = sessionsMap.keys.toList().reversed.toList();

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(top: kDefaultPadding * 1.5),
          itemCount: sessionIds.length,
          itemBuilder: (context, index) {
            final sessionId = sessionIds[index];
            final sessionLines = sessionsMap[sessionId]!;

            return _SessionWidget(
              sessionId: sessionId,
              lines: sessionLines,
              fullText: sessionLines.map((e) => e.text).join("\n"),
            );
          },
        );
      },
    );
  }
}

class _SessionWidget extends StatelessWidget {
  final int sessionId;
  final List<TerminalLine> lines;
  final String fullText;

  const _SessionWidget({
    required this.sessionId,
    required this.lines,
    required this.fullText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kSmallPadding),
      margin: const EdgeInsets.only(top: kSmallPadding),
      decoration: BoxDecoration(
        color: sessionId % 2 == 0
            ? Colors.white.withAlpha(5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(kSmallPadding),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildGroupedLines(context),
          ),
          if (lines.length > 1)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: fullText));
                  showMessage("تم نسخ مخرجات العملية بالكامل", isError: false);
                },
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.copy, size: kLargeFont),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedLines(BuildContext context) {
    if (lines.isEmpty) return [];

    final List<Widget> widgets = [];
    List<TerminalLine> currentGroup = [];

    LineType currentType = lines.first.type;
    bool currentIsCommand = lines.first.text.trim().startsWith("~");

    for (var line in lines) {
      final bool lineIsCommand = line.text.trim().startsWith("~");

      if (line.type == currentType &&
          lineIsCommand == currentIsCommand &&
          !lineIsCommand) {
        currentGroup.add(line);
      } else {
        widgets.add(
          _TextGroup(
            group: currentGroup,
            type: currentType,
            isCommand: currentIsCommand,
          ),
        );
        currentGroup = [line];
        currentType = line.type;
        currentIsCommand = lineIsCommand;
      }
    }
    widgets.add(
      _TextGroup(
        group: currentGroup,
        type: currentType,
        isCommand: currentIsCommand,
      ),
    );

    return widgets;
  }
}

class _TextGroup extends StatelessWidget {
  final List<TerminalLine> group;
  final LineType type;
  final bool isCommand;

  const _TextGroup({
    required this.group,
    required this.type,
    this.isCommand = false,
  });

  @override
  Widget build(BuildContext context) {
    final String combinedText = group.map((e) => e.text).join("\n");
    if (combinedText.isEmpty) return const SizedBox.shrink();

    return SelectableText(
      combinedText,
      style: TextStyle(
        fontSize: kSmallFont,
        color: _getLineColor(type),
        fontStyle: isCommand ? FontStyle.italic : FontStyle.normal,
        fontWeight: (type != LineType.normal || isCommand)
            ? FontWeight.bold
            : null,
        height: isCommand ? 2.2 : 1.5,
      ),
    );
  }

  Color _getLineColor(LineType type) {
    switch (type) {
      case LineType.error:
        return Colors.redAccent;
      case LineType.warning:
        return Colors.orangeAccent;
      case LineType.success:
        return Colors.green;
      case LineType.info:
        return Colors.blueAccent;
      case LineType.normal:
        return Colors.white;
    }
  }
}
