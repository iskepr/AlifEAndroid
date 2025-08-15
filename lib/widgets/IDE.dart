import 'package:flutter/material.dart';
import 'package:alifeditor/widgets/Highlighter.dart' as highlighter;
import 'package:shared_preferences/shared_preferences.dart';

class IDE extends StatefulWidget {
  const IDE({super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  @override
  void initState() {
    super.initState();
    loadSettings();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  bool enableSyntaxHighlighting = false;

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getBool('enable_syntax_highlighting');
    setState(() {
      enableSyntaxHighlighting = savedSettings ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final linesCount = widget.controller.text.split('\n').length;
    final lineNumbers = List.generate(
      linesCount,
      (index) => "${index + 1}",
    ).join('\n');

    final screenWidth = MediaQuery.of(context).size.width;

    final mainstyle = TextStyle(
      fontSize: 15,
      height: 1.4,
      letterSpacing: 0,
      wordSpacing: 0,
      fontFamily: 'Tajawal',
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenWidth - 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        if (!enableSyntaxHighlighting)
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: widget.controller,
                              builder: (context, value, _) {
                                return RichText(
                                  text: TextSpan(
                                    children: highlighter.alifHighlight(
                                      value.text,
                                    ),
                                    style: mainstyle,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                );
                              },
                            ),
                          ),

                        TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          maxLines: null,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: mainstyle.copyWith(
                            color: enableSyntaxHighlighting
                                ? Colors.white
                                : Colors.transparent,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(0),
                            hintTextDirection: TextDirection.rtl,
                            hintText: 'اكتب شفرة لغة ألف هنا...',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    lineNumbers,
                    textAlign: TextAlign.center,
                    style: mainstyle.copyWith(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
