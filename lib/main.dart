import 'dart:io';
import 'package:alifeditor/widgets/IDE.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets/terminal.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "مُحرر لغة ألف",
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
    const platform = MethodChannel('alif/native');

    try {
      final libDir = await platform.invokeMethod<String>('getNativeLibDir');

      setState(() {
        alifBinPath = "$libDir/libalif.so";
        // output += "تم تحميل لغة ألف اصدار 5.0.0\n";
      });
    } catch (e, s) {
      setState(() {
        output += "خطأ أثناء جلب مسار لغة ألف: $e\n$s";
      });
    }
  }

  Future<void> runAlifCode() async {
    if (alifBinPath == null) {
      setState(() {
        output += "لغة ألف ليست متاحه حتى الان!\n";
      });
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

      setState(() {
        runningProcess = process;
        // output += "بدأ تشغيل لغة ألف...\n";
      });

      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        setState(() {
          output += data;
        });
      });

      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        if (!data.toLowerCase().contains("warning")) {
          setState(() {
            output += "خطأ: $data";
          });
        }
      });

      process.exitCode.then((code) {
        setState(() {
          if (code != 0) {
            output += "حدث خطأ في اللغة او الشفرة\n";
          }
        });
      });
    } catch (e, s) {
      setState(() {
        output += "استثناء أثناء التشغيل: $e\n$s";
      });
    }
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
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('تشغيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5b3398),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: runAlifCode,
                  ),
                  Text(
                    'أدخل شفرة الف',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
