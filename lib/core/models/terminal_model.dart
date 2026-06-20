enum LineType { normal, error, warning, success, info }

class TerminalLine {
  final String text;
  final int sessionId;
  final LineType type;

  TerminalLine({
    required this.text,
    required this.sessionId,
    this.type = LineType.normal,
  });
}
