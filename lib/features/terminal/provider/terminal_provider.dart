import "dart:io";

import "package:code_forge/code_forge.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../../constants.dart";
import "../../../core/helpers/hive_helper.dart";
import "../../../core/models/data_typs.dart";
import "../../../core/providers/settings_provider.dart";
import "../../../core/providers/workspace_provider.dart";
import "../functions/handle_commands.dart";
import "../utils/terminal_parser.dart";

class TerminalProvider extends ChangeNotifier {
  late final FocusNode terminalFocus;
  final SettingsProvider _settings;
  WorkspaceProvider? _workspace;

  final List<TerminalLine> outputLines = [];
  String get output => outputLines.map((e) => e.text).join("\n");

  int currentSessionId = 0;
  String terminalHint = "أدخل الأمر...";
  Process? runningProcess;

  static const int _maxBashHistory = 100;
  List<String> suggestions = [];
  List<String> history = [];

  TerminalProvider(this._settings, [this._workspace]) {
    terminalFocus = FocusNode();
    history = HiveHelper.getListDataByKey<String>(
      kBoxSettings,
      kKeyBashHistory,
    );
  }

  void updateWorkspace(WorkspaceProvider workspace) {
    _workspace = workspace;
  }

  void startNewTerminalSession() {
    currentSessionId++;
    notifyListeners();
  }

  Future<void> addOutput(
    String text, {
    bool newLine = true,
    LineType? type,
  }) async {
    final Map<String, dynamic> params = {
      "text": text,
      "currentLines": List<TerminalLine>.from(outputLines),
      "sessionId": currentSessionId,
      "type": type,
      "newLine": newLine,
      "errorLabel": l10n.error,
      "warningLabel": l10n.warning,
    };

    final List<TerminalLine> processedLines = await compute(
      parseTerminalOutputInBackground,
      params,
    );

    outputLines.clear();
    outputLines.addAll(processedLines);

    final LineType finalType =
        type ??
        (outputLines.isNotEmpty ? outputLines.last.type : LineType.normal);

    final hasError =
        type == LineType.error ||
        processedLines.any((line) => line.type == LineType.error);

    if (hasError && _workspace != null) {
      final fullContent = processedLines.map((e) => e.text).join("\n");
      final diagnostic = _parsePythonArabicError(fullContent);

      if (diagnostic != null) {
        _workspace!.codeController.diagnosticsNotifier.value = [diagnostic];
      }
    }

    notifyListeners();

    _settings.runVibration(
      pattern: hasError
          ? [0, 100, 50, 100]
          : finalType == LineType.warning
          ? [0, 100]
          : [0, 50],
      duration: finalType == LineType.warning ? 100 : 0,
    );
  }

  void clearOutput() {
    outputLines.clear();
    currentSessionId = 0;
  }

  Future<void> saveHistory(String command) async {
    if (runningProcess != null) return;
    final cleaned = command.trim();
    if (cleaned.isEmpty) return;

    history.removeWhere((item) => item.toLowerCase() == cleaned.toLowerCase());
    history.insert(0, cleaned);
    if (history.length > _maxBashHistory) {
      history.removeRange(_maxBashHistory, history.length);
    }

    await HiveHelper.saveListDataByKey<String>(
      kBoxSettings,
      kKeyBashHistory,
      history,
    );
    notifyListeners();
  }

  void updateSuggestions(String text) {
    if (!_settings.get<bool>(AppSetting.enableSuggestions)) {
      if (suggestions.isNotEmpty) {
        suggestions = [];
        notifyListeners();
      }
      return;
    }

    final rawInput = text.trimLeft();
    final segments = rawInput.split(RegExp(r"\s+"));
    if (segments.isEmpty || segments.first.isEmpty || rawInput.contains(" ")) {
      if (suggestions.isNotEmpty) {
        suggestions = [];
        notifyListeners();
      }
      return;
    }

    final lowerInput = rawInput.toLowerCase();
    final merged = <String>{
      ...history.where((cmd) => cmd.toLowerCase().startsWith(lowerInput)),
      ...getTerminalSuggestions(segments.first),
    }.toList();

    if (!listEquals(merged, suggestions)) {
      suggestions = merged;
      notifyListeners();
    }
  }

  void clearSuggestions() {
    if (suggestions.isNotEmpty) {
      suggestions = [];
      notifyListeners();
    }
  }

  void sendOutput(String input) {
    runningProcess?.stdin.writeln(input);
    addOutput(input);
  }

  void updateTerminalHint(String? hint) {
    terminalHint = hint ?? "أدخل الأمر...";
    notifyListeners();
  }

  void editProcess(Process process) {
    runningProcess = process;
    notifyListeners();
  }

  void clearRunningProcess() {
    runningProcess?.kill();
    runningProcess = null;
    terminalHint = "أدخل الأمر...";
    notifyListeners();
  }

  @override
  void dispose() {
    terminalFocus.dispose();
    runningProcess?.kill();
    super.dispose();
  }
}

String _sanitizeTerminalText(String text) {
  var output = text;
  output = output.replaceAllMapped(
    RegExp(r"\x1B\]8;;([^\x07\x1B]*)\x1B\\(.*?)\x1B\]8;;\x1B\\", dotAll: true),
    (match) {
      final url = match.group(1) ?? "";
      final visible = match.group(2) ?? "";
      return "$visible\u0000$url\u0001";
    },
  );
  output = output.replaceAll(RegExp(r"\x1B\][^\x07\x1B]*(?:\x07|\x1B\\)"), "");
  output = output.replaceAll(RegExp(r"\x1B\[[0-?]*[ -/]*[@-~]"), "");
  output = output.replaceAll("\x1B\\", "");
  return output;
}

List<TerminalLine> parseTerminalOutputInBackground(
  Map<String, dynamic> params,
) {
  final String text = _sanitizeTerminalText(params["text"] as String);
  final List<TerminalLine> currentLines = List<TerminalLine>.from(
    params["currentLines"],
  );
  final int sessionId = params["sessionId"] as int;
  final LineType? type = params["type"] as LineType?;
  final bool? isError = params["isError"] as bool?;
  final String errorLabel = params["errorLabel"] as String;
  final String warningLabel = params["warningLabel"] as String;

  if (currentLines.isEmpty) {
    currentLines.add(
      TerminalLine(text: "", sessionId: sessionId, type: LineType.normal),
    );
  }

  final lineType = getLineType(text, type, isError, errorLabel, warningLabel);
  final String prefix = lineType[0];
  final LineType currentType = type ?? lineType[1];

  final String lastLineText = currentLines.removeLast().text;

  final String fullText =
      lastLineText +
      (lastLineText.isEmpty ? prefix : "") +
      text +
      (params["newLine"] ? "\n" : "");

  final List<String> rawLines = fullText.split("\n");

  for (int i = 0; i < rawLines.length; i++) {
    String processedLine = rawLines[i];
    if (processedLine.contains("\r")) {
      processedLine = processedLine.substring(
        processedLine.lastIndexOf("\r") + 1,
      );
    }

    if (i < rawLines.length - 1) {
      currentLines.add(
        TerminalLine(
          text: processedLine,
          sessionId: sessionId,
          type: currentType,
        ),
      );
    } else {
      if (fullText.endsWith("\n") && processedLine.isEmpty) {
        currentLines.add(
          TerminalLine(text: "", sessionId: sessionId, type: LineType.normal),
        );
      } else {
        currentLines.add(
          TerminalLine(
            text: processedLine,
            sessionId: sessionId,
            type: currentType,
          ),
        );
      }
    }
  }

  if (currentLines.length > 300) {
    currentLines.removeRange(0, currentLines.length - 300);
  }

  return currentLines;
}

DiagnosticLine? _parsePythonArabicError(String text) {
  final regex = RegExp(
    r"السطر[^\d\n\r]*([0-9\u0660-\u0669]+)[\s\S]*?خطأ[^\s:]*:\s*(.+)",
  );

  final match = regex.firstMatch(text);
  if (match == null) return null;

  final message = match.group(2)?.trim() ?? "";

  String rawLine = match.group(1) ?? "1";
  const arabicDigits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
  for (int i = 0; i < arabicDigits.length; i++) {
    rawLine = rawLine.replaceAll(arabicDigits[i], i.toString());
  }

  final parsedLine = int.tryParse(rawLine) ?? 1;
  final line = (parsedLine < 1 ? 1 : parsedLine) - 1;
  const col = 0;

  return DiagnosticLine(
    message: message,
    severity: 1,
    range: {
      "start": {"line": line, "character": col},
      "end": {"line": line, "character": col + 1},
    },
  );
}
