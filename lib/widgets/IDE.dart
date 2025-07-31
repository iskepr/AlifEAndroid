import 'package:flutter/material.dart';
import 'package:alifeditor/widgets/Highlighter.dart' as highlighter;

class IDE extends StatefulWidget {
  const IDE({super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<IDE> createState() => _IDEState();
}

class _IDEState extends State<IDE> {
  @override
  Widget build(BuildContext context) {
    final linesCount = widget.controller.text.split('\n').length;
    final lineNumbers = List.generate(
      linesCount,
      (index) => "${index + 1}",
    ).join('\n');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 15,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: widget.controller,
                            builder: (context, value, _) {
                              return RichText(
                                text: TextSpan(
                                  children: highlighter.alifHighlight(
                                    value.text,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    fontFamily: 'Tajawal',
                                  ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0x00FFC107),
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
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    lineNumbers,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                      fontSize: 14,
                    ),
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
