import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';

class Terminal extends StatefulWidget {
  const Terminal({
    super.key,
    required this.inputController,
    required this.output,
    required this.alifBinPath,
    required this.runningProcess,
    required this.onClearOutput,
    required this.onSendInput,
  });

  final TextEditingController inputController;
  final String output;
  final String? alifBinPath;
  final Process? runningProcess;
  final VoidCallback onClearOutput;
  final Function(String) onSendInput;

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 5, bottom: 30, left: 10, right: 10),
      decoration: BoxDecoration(
        color: const Color(0x60000000),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x182d5555), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2079ffff),
            offset: Offset(2, 2),
            blurRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الطرفية',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.output.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.clear_all_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: widget.onClearOutput,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    widget.output.isEmpty
                        ? 'ستظهر النتائج هنا...'
                        : widget.output,
                    style: const TextStyle(
                      fontFamily: 'Cascadia Code',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              if (widget.runningProcess != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.inputController,
                        onSubmitted: widget.onSendInput,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Cascadia Code',
                        ),
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
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
