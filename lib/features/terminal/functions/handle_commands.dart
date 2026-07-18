import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../constants.dart";
import "../../../core/providers/workspace_provider.dart";
import "../provider/terminal_provider.dart";
import "run_command.dart";

enum BuiltIn {
  clear(["مسح", "clear"], "تنظيف الشاشة"),
  pwd(["مسار", "pwd"], "عرض مسار العمل الحالي"),
  cd(["انتقل", "cd"], "تغيير مسار العمل"),
  echo(["طباعة", "اطبع", "echo"], "طباعة نص على الشاشة"),
  date(["تاريخ", "date"], "عرض الوقت والتاريخ الحالي"),
  ls(["عرض", "ls"], "عرض محتويات المجلد الحالي"),
  mkdir(["مجلد", "mkdir"], "إنشاء مجلد جديد"),
  touch(["ملف", "touch"], "إنشاء ملف جديد فارغ"),
  rm(["حذف", "rm"], "حذف ملف أو مجلد"),
  help(["مساعدة", "help"], "عرض هذه القائمة"),
  run(["تشغيل", "بدء", "run"], "تشغيل التطبيق"),
  exit(["إنهاء", "انهاء", "exit"], "إنهاء العملية الحالية");

  final List<String> aliases;
  final String description;
  const BuiltIn(this.aliases, this.description);
}

Future<bool> handleCommands(
  BuildContext context,
  List<String> commandParts,
) async {
  if (commandParts.isEmpty) return false;

  final terminal = context.read<TerminalProvider>();
  final workspace = context.read<WorkspaceProvider>();

  final command = commandParts[0].toLowerCase();
  final args = commandParts.length > 1 ? commandParts.sublist(1) : <String>[];

  BuiltIn? matchedCmd;
  for (final cmd in BuiltIn.values.toList()) {
    if (cmd.aliases.contains(command)) {
      matchedCmd = cmd;
      break;
    }
  }

  if (matchedCmd == null) return false;

  switch (matchedCmd) {
    case BuiltIn.clear:
      terminal.clearOutput();
      return true;
    case BuiltIn.pwd:
      terminal.addOutput(_getCurrentPath(workspace));
      return true;
    case BuiltIn.cd:
      await _handleCdCommand(
        workspace,
        terminal,
        args.isEmpty ? kHomeDir : args[0],
      );
      return true;
    case BuiltIn.echo:
      terminal.addOutput(args.join(" "));
      return true;
    case BuiltIn.date:
      terminal.addOutput(DateTime.now().toString());
      return true;
    case BuiltIn.ls:
      await _handleLsCommand(workspace, terminal, args);
      return true;
    case BuiltIn.mkdir:
      await _handleMkdirCommand(workspace, terminal, args);
      return true;
    case BuiltIn.touch:
      await _handleTouchCommand(workspace, terminal, args);
      return true;
    case BuiltIn.rm:
      await _handleRmCommand(workspace, terminal, args);
      return true;
    case BuiltIn.help:
      _showHelp(terminal);
      return true;
    case BuiltIn.exit:
      terminal.clearRunningProcess();
      terminal.addOutput("\n ---");
      return true;
    case BuiltIn.run:
      runCommand(context, kAlifBin);
      return true;
  }
}

String _getCurrentPath(WorkspaceProvider workspace) =>
    workspace.workspacePath?.isNotEmpty == true
    ? workspace.workspacePath!
    : kHomeDir;

String _resolvePath(String currentPath, String targetDir) {
  if (targetDir.startsWith("/")) return targetDir;

  String newPath = Uri.file("$currentPath/").resolve(targetDir).toFilePath();
  if (newPath.endsWith("/") && newPath.length > 1) {
    newPath = newPath.substring(0, newPath.length - 1);
  }
  return newPath;
}

void _showHelp(TerminalProvider terminal) {
  final buffer = StringBuffer("الأوامر الداخلية المتاحة:\n");
  for (final cmd in BuiltIn.values.toList()) {
    final aliasesStr = cmd.aliases.join(" | ");
    buffer.writeln("$aliasesStr: ${cmd.description}");
  }
  terminal.addOutput(buffer.toString().trim(), isError: false);
}

Future<void> _handleCdCommand(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  String targetDir,
) async {
  final newPath = _resolvePath(_getCurrentPath(workspace), targetDir);
  final dir = Directory(newPath);

  if (await dir.exists()) {
    workspace.setWorkspacePath(dir.path);
    terminal.addOutput("تم الانتقال إلى: ${dir.path}", isError: false);
    await _handleLsCommand(workspace, terminal, []);
  } else {
    terminal.addOutput(
      "cd: $targetDir: لا يوجد مجلد بهذا الاسم",
      isError: true,
    );
  }
  terminal.clearRunningProcess();
}

Future<void> _handleLsCommand(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> args,
) async {
  final targetDir = args.isEmpty
      ? _getCurrentPath(workspace)
      : _resolvePath(_getCurrentPath(workspace), args[0]);
  final dir = Directory(targetDir);

  if (!await dir.exists()) {
    terminal.addOutput(
      "ls: $targetDir: لا يوجد مجلد بهذا الاسم",
      isError: true,
    );
    return;
  }

  try {
    final List<FileSystemEntity> entities = await dir.list().toList();
    if (entities.isEmpty) return;

    final directories = entities
        .whereType<Directory>()
        .map((e) => "${e.path.split(Platform.pathSeparator).last}/")
        .toList();
    final files = entities
        .whereType<File>()
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .toList();

    directories.sort();
    files.sort();

    final output = [...directories, ...files].join("  ");
    terminal.addOutput(output);
  } catch (e) {
    terminal.addOutput("ls: لا يمكن قراءة المحتوى: $e", isError: true);
  }
}

Future<void> _handleMkdirCommand(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> args,
) async {
  if (args.isEmpty) {
    terminal.addOutput("mkdir: يجب تحديد اسم المجلد", isError: true);
    return;
  }

  final newPath = _resolvePath(_getCurrentPath(workspace), args[0]);
  final dir = Directory(newPath);

  if (await dir.exists()) {
    terminal.addOutput(
      "mkdir: المجلد '${args[0]}' موجود بالفعل",
      isError: true,
    );
  } else {
    await dir.create(recursive: true);
  }
}

Future<void> _handleTouchCommand(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> args,
) async {
  if (args.isEmpty) {
    terminal.addOutput("touch: يجب تحديد اسم الملف", isError: true);
    return;
  }

  final newPath = _resolvePath(_getCurrentPath(workspace), args[0]);
  final file = File(newPath);

  if (!await file.exists()) {
    await file.create();
  } else {
    final now = DateTime.now();
    await file.setLastModified(now);
    await file.setLastAccessed(now);
  }
}

Future<void> _handleRmCommand(
  WorkspaceProvider workspace,
  TerminalProvider terminal,
  List<String> args,
) async {
  if (args.isEmpty) {
    terminal.addOutput(
      "rm: يجب تحديد اسم الملف أو المجلد للحذف",
      isError: true,
    );
    return;
  }

  final isRecursive = args.contains("-r") || args.contains("-rf");
  final targetName = args.last;
  final targetPath = _resolvePath(_getCurrentPath(workspace), targetName);

  final type = await FileSystemEntity.type(targetPath);

  try {
    if (type == FileSystemEntityType.file) {
      await File(targetPath).delete();
    } else if (type == FileSystemEntityType.directory) {
      if (isRecursive) {
        await Directory(targetPath).delete(recursive: true);
      } else {
        terminal.addOutput(
          "rm: '$targetName' مجلد، استخدم -r لحذفه",
          isError: true,
        );
      }
    } else {
      terminal.addOutput(
        "rm: $targetName: لا يوجد ملف أو مجلد بهذا الاسم",
        isError: true,
      );
    }
  } catch (e) {
    terminal.addOutput("rm: فشل الحذف: $e", isError: true);
  }
}

String getPromptPath(WorkspaceProvider workspace) {
  final path = _getCurrentPath(workspace);
  if (path.startsWith(kHomeDir)) {
    return path.replaceFirst(kHomeDir, "~");
  }
  return path;
}
