import 'dart:io';
import 'package:alifeditor/widgets/AppBar.dart';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:alifeditor/widgets/Shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  TextEditingController controller = TextEditingController(text: "");
  TextEditingController inputController = TextEditingController();

  String? alifBinPath;
  late String runtimeDir;

  final FocusNode editorFocus = FocusNode();

  final ValueNotifier<String> output = ValueNotifier("");
  final ValueNotifier<Process?> runningProcess = ValueNotifier(null);

  final ValueNotifier<String?> currentFilePath = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    setupAlif();
  }

  Future<void> setupAlif() async {
    const platform = MethodChannel('alif/native');

    try {
      final langDir = await platform.invokeMethod<String>('prepareAlifRuntime');
      if (langDir == null) {
        output.value += "خطأ: ملف لغة الف مش متاح!\n";
        return;
      }

      alifBinPath = langDir;
      output.value += "تم تحميل لغة ألف اصدار 5.1.0\n";
    } catch (e, s) {
      output.value += "خطأ أثناء جلب مسار لغة ألف: $e\n$s";
    }
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      output.value += "خطأ: لغة الف ليست متاحة\n";
      return;
    }

    try {
      final aliflang = File(alifBinPath!);
      await Process.run('chmod', ['755', aliflang.path]);
      final libDir = alifBinPath!.replaceAll('/libalif.so', '');

      final process = await Process.start(
        "/system/bin/linker64",
        [aliflang.path, "-ص", controller.text],
        environment: {'LD_LIBRARY_PATH': libDir},
      );

      runningProcess.value = process;

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        output.value += data;
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        if (!data.toLowerCase().contains("warning")) {
          output.value += "خطأ: $data";
        }
      });

      process.exitCode.then((code) {
        if (code != 0) output.value += "حدث خطأ في الشفرة\n";
      });
    } catch (e, s) {
      output.value += "استثناء أثناء التشغيل: $e\n$s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF081433),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Background.webp"),
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),
          child: Column(
            children: [
              AlifAppBar(
                controller: controller,
                currentFilePath: currentFilePath,
                inputController: inputController,
                output: output,
                alifBinPath: alifBinPath,
                runningProcess: runningProcess,
                runAlifCode: runAlifCode,
              ),
              IDE(controller: controller, focusNode: editorFocus),
              KeyShortcuts(controller: controller, focusNode: editorFocus),
            ],
          ),
        ),
      ),
    );
  }
}
