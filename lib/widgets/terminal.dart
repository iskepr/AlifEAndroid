import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Terminal extends StatefulWidget {
  const Terminal({
    super.key,
    required this.inputController,
    required this.output,
    required this.alifBinPath,
    required this.runningProcess,
    required this.onClearOutput,
    required this.onSendInput,
    required this.runAlifCode,
  });

  final TextEditingController inputController;
  final ValueNotifier<String> output;
  final String? alifBinPath;
  final Process? runningProcess;
  final VoidCallback onClearOutput;
  final Function(String) onSendInput;
  final VoidCallback runAlifCode;

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final baseHeight = MediaQuery.of(context).size.height * 0.6;
    final extraHeight = keyboardHeight > 0 ? keyboardHeight / 1.5 : 0;
    final totalHeight = baseHeight + extraHeight;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
          bottom: keyboardHeight,
        ),
        height: totalHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0830),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.clear_all_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: widget.onClearOutput,
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.play,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: widget.runAlifCode,
                      ),
                    ],
                  ),
                  const Text(
                    'الطرفية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: widget.output,
                builder: (context, value, _) => SingleChildScrollView(
                  reverse: true,
                  child: SelectableText(
                    value.isEmpty ? '' : value,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.inputController,
                    onSubmitted: widget.onSendInput,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "ادخل هنا",
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      widget.onSendInput(widget.inputController.text),
                  icon: const Icon(LucideIcons.arrowRight, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
