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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                                  style: mainstyle.copyWith(
                                    height: screenHeight > 700
                                        ? screenWidth < 1200
                                              ? screenHeight / 850
                                              : screenHeight / 510
                                        : null,
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
                          style: mainstyle.copyWith(
                            color: Colors.transparent,
                            letterSpacing: screenHeight > 700
                                ? screenWidth < 1200
                                      ? -screenWidth / 1200
                                      : -screenWidth / 2000
                                : null,
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
