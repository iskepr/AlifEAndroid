import 'dart:convert';
import 'dart:io';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'widgets/terminal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "مُحرر طيف",
    theme: ThemeData(fontFamily: 'Tajawal'),
    home: AlifRunner(),
  ),
);

class AlifRunner extends StatefulWidget {
  const AlifRunner({super.key});

  @override
  State<AlifRunner> createState() => _AlifRunnerState();
}

class _AlifRunnerState extends State<AlifRunner> {
  TextEditingController controller = TextEditingController(
    text: """
# هذا البرنامج يقوم بطباعة الاعداد الاولية ضمن المدى المعطى له
دالة هل_اولي(عدد):
	اذا عدد < 2:
		ارجع
	اذا عدد == 2:
		اطبع(عدد)
		ارجع
	اذا ليس عدد \\\\ 2:
		ارجع
	لاجل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
		اذا ليس عدد \\\\ مقسوم:
			ارجع
	اطبع(عدد)
اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن):
	هل_اولي(ب)
اطبع(م"تم إيجاد الاعداد الاولية ضمن العدد { ن }")
""",
  );

  TextEditingController inputController = TextEditingController();

  final ValueNotifier<String> output = ValueNotifier("");

  String? alifBinPath;
  Process? runningProcess;
  String? currentFilePath;

  @override
  void initState() {
    super.initState();
    setupAlif();
  }

  Future<void> setupAlif() async {
    const platform = MethodChannel('alif/native');

    try {
      final libDir = await platform.invokeMethod<String>('getNativeLibDir');
      alifBinPath = "$libDir/libalif.so";
      output.value += "تم تحميل لغة ألف اصدار 5.0.0\n";
    } catch (e, s) {
      output.value += "خطأ أثناء جلب مسار لغة ألف: $e\n$s";
    }
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      output.value += "لغة ألف ليست متاحه حتى الان!\n";
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final scriptFile = File('${tempDir.path}/code.alif');
      await scriptFile.writeAsString(controller.text);

      final libDir = alifBinPath!.replaceAll('/libalif.so', '');

      final process = await Process.start(
        alifBinPath!,
        [scriptFile.path],
        environment: {'LD_LIBRARY_PATH': libDir},
      );

      runningProcess = process;

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        output.value += data;
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        if (!data.toLowerCase().contains("warning")) {
          output.value += "خطأ: $data";
        }
      });

      process.exitCode.then((code) {
        if (code != 0) {
          output.value += "حدث خطأ في اللغة او الشفرة\n";
        }
      });
    } catch (e, s) {
      output.value += "استثناء أثناء التشغيل: $e\n$s";
    }
  }

  void sendInput(String text) {
    if (runningProcess != null) {
      runningProcess!.stdin.writeln(text);
      output.value += "$text\n";
      inputController.clear();
    }
  }

  Future<void> saveCode() async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(controller.text));

      final path = await FileSaver.instance.saveAs(
        name: "شفرة",
        bytes: bytes,
        fileExtension: "alif",
        mimeType: MimeType.other,
      );

      if (path == null || path.isEmpty) {
        output.value += "تم إلغاء الحفظ.\n";
        return;
      }

      currentFilePath = path;
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
        final file = File(path);
        final code = await file.readAsString();
        setState(() {
          controller.text = code;
          currentFilePath = path;
        });
      }
    } catch (e) {
      output.value += "خطأ أثناء الفتح: $e\n";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081433),

      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background.webp"),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
              child: Row(
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
                        onPressed: saveCode,
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
                              runningProcess: runningProcess,
                              runAlifCode: runAlifCode,
                              onClearOutput: () => output.value = '',
                              onSendInput: (input) {
                                runningProcess?.stdin.writeln(input);
                                output.value += "$input\n";
                                inputController.clear();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    currentFilePath?.split('/').last ?? "مُحرر طيف",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: currentFilePath != null ? 15 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IDE(controller: controller, runAlifCode: runAlifCode),
          ],
        ),
      ),
    );
  }
}
