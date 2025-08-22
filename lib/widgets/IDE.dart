import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/alifDark.dart';
import 'package:highlight/languages/alif.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IDE extends StatefulWidget {
  const IDE({super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  bool enableSyntaxHighlighting = false;
  late CodeController codeController;

  @override
  void initState() {
    super.initState();
    _createCodeController();
    loadSettings();
  }

  void _createCodeController() {
    codeController = CodeController(
      text: widget.controller.text,
      language: alif,
      patternMap: enableSyntaxHighlighting
          ? {}
          : {'': const TextStyle(color: Colors.transparent)},
    );

    codeController.addListener(() {
      if (widget.controller.text != codeController.text) {
        widget.controller.text = codeController.text;
      }
    });

    widget.controller.addListener(() {
      if (codeController.text != widget.controller.text) {
        codeController.text = widget.controller.text;
      }
    });
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enableSyntaxHighlighting =
          prefs.getBool('enable_syntax_highlighting') ?? true;
      _createCodeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: CodeTheme(
            data: CodeThemeData(styles: {...alifDarkTheme}),
            child: CodeField(
              controller: codeController,
              textStyle: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
