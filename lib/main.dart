import 'dart:io';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets/terminal.dart';

void main() => runApp(const MaterialApp(home: AlifRunner()));

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
	اذا عدد == 2:
		اطبع(عدد)
		ارجع
	اذا عدد <= 1 او ليس عدد \\ 2:
		ارجع
	لاجل مقسوم في مدى(3, عدد):
		اذا ليس عدد \\ مقسوم:
			استمر
	اطبع(عدد)
اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن):
	هل_اولي(ب)
اطبع(م"تم إيجاد الاعداد الاولية ضمن العدد { ن }")
""",
  );

  TextEditingController inputController = TextEditingController();

  String output = "";
  String? alifBinPath;
  Process? runningProcess;

  @override
  void initState() {
    super.initState();
    setupAlif();
  }

  Future<void> setupAlif() async {
    final binData = await rootBundle.load('assets/alif');
    final libcData = await rootBundle.load('assets/libc++_shared.so');

    final tempDir = await getTemporaryDirectory();

    final alifBinFile = File('${tempDir.path}/alif');
    final libcFile = File('${tempDir.path}/libc++_shared.so');

    await alifBinFile.writeAsBytes(binData.buffer.asUint8List());
    await libcFile.writeAsBytes(libcData.buffer.asUint8List());

    await Process.run('chmod', ['+x', alifBinFile.path]);

    setState(() {
      alifBinPath = alifBinFile.path;
    });
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      setState(() {
        output = "خطأ في تحميل لغة ألف!";
      });
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final scriptFile = File('${tempDir.path}/code.alif');
    await scriptFile.writeAsString(controller.text);

    final process = await Process.start(
      alifBinPath!,
      [scriptFile.path],
      environment: {'LD_LIBRARY_PATH': tempDir.path},
    );

    setState(() {
      runningProcess = process;
      output = "";
    });

    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      setState(() {
        output += data;
      });
    });

    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      setState(() {
        output += data;
      });
    });
  }

  void sendInput(String text) {
    if (runningProcess != null) {
      runningProcess!.stdin.writeln(text);
      setState(() {
        output += "$text\n";
        inputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B46),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: IDE(controller: controller, runAlifCode: runAlifCode),
            ),
            Expanded(
              flex: 5,
              child: Terminal(
                inputController: inputController,
                output: output,
                alifBinPath: alifBinPath,
                runningProcess: runningProcess,
                onClearOutput: () => setState(() => output = ''),
                onSendInput: (input) {
                  runningProcess?.stdin.writeln(input);
                  inputController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
