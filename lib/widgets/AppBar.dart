import 'dart:convert';
import 'dart:io';
import 'package:alifeditor/widgets/OpenedFiles.dart';
import 'package:alifeditor/widgets/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './terminal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlifAppBar extends StatefulWidget {
  const AlifAppBar({
    super.key,
    required this.controller,
    required this.currentFilePath,
    required this.inputController,
    required this.output,
    required this.alifBinPath,
    required this.runningProcess,
    required this.runAlifCode,
  });

  final TextEditingController controller;
  final ValueNotifier<String?> currentFilePath;
  final TextEditingController inputController;
  final ValueNotifier<String> output;
  final String? alifBinPath;
  final ValueNotifier<Process?> runningProcess;
  final VoidCallback runAlifCode;

  @override
  State<AlifAppBar> createState() => _AlifAppBarState();
}

class _AlifAppBarState extends State<AlifAppBar> {
  // مفتاح للوصول لحالة OpenedFiles وتعديل القائمة مباشرة
  final GlobalKey<OpenedFilesState> _openedFilesKey =
      GlobalKey<OpenedFilesState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> output = widget.output;
    ValueNotifier<String?> currentFilePath = widget.currentFilePath;
    TextEditingController controller = widget.controller;
    TextEditingController inputController = widget.inputController;
    String? alifBinPath = widget.alifBinPath;
    ValueNotifier<Process?> runningProcess = widget.runningProcess;
    VoidCallback runAlifCode = widget.runAlifCode;

    Future<void> saveCode(String code, String? fileName) async {
      try {
        final bytes = Uint8List.fromList(utf8.encode(code));

        final path = await FileSaver.instance.saveAs(
          name: fileName ?? "شفرة",
          bytes: bytes,
          fileExtension: "alif",
          mimeType: MimeType.other,
        );

        if (path == null || path.isEmpty) {
          output.value += "تم إلغاء الحفظ.\n";
          return;
        }

        currentFilePath.value = path;
        output.value += "تم الحفظ في: $path\n";
      } catch (e) {
        output.value += "خطأ أثناء الحفظ: $e\n";
      }
    }

    Future<void> openCode() async {
      FilePickerResult? result;
      try {
        if (Platform.isAndroid) {
          result = await FilePicker.platform.pickFiles(type: FileType.any);
        } else {
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['alif', "aliflib", "الف"],
          );
        }

        if (result != null && result.files.single.path != null) {
          final path = result.files.single.path!;
          final code = await File(path).readAsString();
          setState(() {
            controller.text = code;
            currentFilePath.value = path;
          });

          final prefs = await SharedPreferences.getInstance();

          List<Map<String, String>> filesList = [];
          final savedFiles = prefs.getString('opened_files');
          if (savedFiles != null) {
            final decoded = jsonDecode(savedFiles);
            if (decoded is List) {
              filesList = decoded.map<Map<String, String>>((item) {
                return {
                  "Name": item["Name"].toString(),
                  "Path": item["Path"].toString(),
                  "Code": item["Code"].toString(),
                };
              }).toList();
            }
          }

          final fileName = path.split(Platform.pathSeparator).last;
          final existingIndex = filesList.indexWhere((f) => f["Path"] == path);
          if (existingIndex >= 0) {
            filesList[existingIndex] = {
              "Name": fileName,
              "Path": path,
              "Code": code,
            };
          } else {
            filesList.add({"Name": fileName, "Path": path, "Code": code});
          }

          await prefs.setString('opened_files', jsonEncode(filesList));

          _openedFilesKey.currentState?.addOrUpdateFile({
            "Name": fileName,
            "Path": path,
            "Code": code,
          });
        }
      } catch (e) {
        output.value += "خطأ أثناء الفتح: $e\n";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.folderOpen,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: openCode,
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => saveCode(
                      controller.text,
                      currentFilePath.value
                          ?.split('/')
                          .last
                          .replaceAll('.alif', '')
                          .replaceAll('.aliflib', '')
                          .replaceAll('.الف', ''),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => {
                      output.value = '',
                      runAlifCode(),
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Terminal(
                          inputController: inputController,
                          output: output,
                          alifBinPath: alifBinPath,
                          runningProcess: runningProcess.value,
                          runAlifCode: runAlifCode,
                          onClearOutput: () => output.value = '',
                          onSendInput: (input) {
                            runningProcess.value?.stdin.writeln(input);
                            output.value += "$input\n";
                            inputController.clear();
                          },
                        ),
                      ),
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.terminal,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Terminal(
                          inputController: inputController,
                          output: output,
                          alifBinPath: alifBinPath,
                          runningProcess: runningProcess.value,
                          runAlifCode: runAlifCode,
                          onClearOutput: () => output.value = '',
                          onSendInput: (input) {
                            runningProcess.value?.stdin.writeln(input);
                            output.value += "$input\n";
                            inputController.clear();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Settings(),
                  );
                },
                child: Text(
                  "مُحرر طيف",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // مرّر المفتاح هنا
          OpenedFiles(
            key: _openedFilesKey,
            currentFilePath: currentFilePath,
            currentCode: controller,
            output: output,
          ),
        ],
      ),
    );
  }
}
