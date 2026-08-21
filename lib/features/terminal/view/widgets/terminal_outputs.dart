import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";

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
    final lineStyle = TextStyle(
      fontSize: kSmallFont,
      color: isCommand ? Colors.grey : _getLineColor(type),
      fontStyle: isCommand ? FontStyle.italic : FontStyle.normal,
      fontWeight: (type != LineType.normal || isCommand)
          ? FontWeight.bold
          : null,
      height: isCommand ? 2.2 : 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: group.map((line) {
        return SelectableText.rich(
          TextSpan(
            children: _buildTextSpans(line.text, lineStyle),
            style: lineStyle,
          ),
          textDirection: _getTextDirection(line.text),
          textAlign: TextAlign.right,
        );
      }).toList(),
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

  List<TextSpan> _buildTextSpans(String text, TextStyle style) {
    final spans = <TextSpan>[];
    final markerRegex = RegExp(r"(.*?)\u0000(.*?)\u0001", dotAll: true);
    int lastIndex = 0;

    for (final match in markerRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.addAll(
          _buildUrlSpans(text.substring(lastIndex, match.start), style),
        );
      }
      final visible = match.group(1) ?? "";
      final url = match.group(2) ?? "";
      if (visible.isNotEmpty) {
        spans.add(_linkTextSpan(visible, style, url));
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.addAll(_buildUrlSpans(text.substring(lastIndex), style));
    }

    return spans;
  }

  List<TextSpan> _buildUrlSpans(String text, TextStyle style) {
    final spans = <TextSpan>[];
    final urlRegex = RegExp(r"(https?:\/\/[\S]+)");
    int lastMatchEnd = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }
      final url = match.group(0)!;
      spans.add(_linkTextSpan(url, style, url));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return spans;
  }

  TextSpan _linkTextSpan(String display, TextStyle style, String url) {
    return TextSpan(
      text: display,
      style: style.copyWith(
        color: _getLineColor(LineType.warning),
        decoration: TextDecoration.underline,
        decorationColor: _getLineColor(LineType.warning),
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
    );
  }

  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return TextDirection.rtl;

    final arabic = RegExp(r"([\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]|~)");
    final latinDigit = RegExp(r"[A-Za-z0-9]");

    for (final char in trimmed.characters) {
      if (arabic.hasMatch(char)) return TextDirection.rtl;
      if (latinDigit.hasMatch(char)) return TextDirection.ltr;
    }

    return TextDirection.ltr;
  }
}
