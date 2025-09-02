import 'dart:io';
import 'package:alifeditor/widgets/AppBar.dart';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:alifeditor/widgets/Shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
      final libDir = await platform.invokeMethod<String>('getNativeLibDir');
      alifBinPath = "$libDir/libalif.so";
      output.value += "تم تحميل لغة ألف اصدار 5.1.0\n";
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
        if (code != 0) {
          output.value += "حدث خطأ في اللغة او الشفرة\n";
        }
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
          decoration: BoxDecoration(
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
