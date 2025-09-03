import 'package:flutter/material.dart';

class KeyShortcuts extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const KeyShortcuts({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  void _insertText(String value) {
    final text = controller.text;
    final selection = controller.selection;

    final newText = text.replaceRange(selection.start, selection.end, value);
    final newPos = selection.start + value.length;

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newPos),
    );

    focusNode.requestFocus();
  }

  Widget _buildButton(String label, {String? insert}) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: 37,
          maxHeight: 30,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x601A2340),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () => _insertText(insert ?? label),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildButton("⏎", insert: "/س"),
            _buildButton("[", insert: "]"),
            _buildButton("]", insert: "["),
            _buildButton("{", insert: "}"),
            _buildButton("}", insert: "{"),
            _buildButton(","),
            _buildButton("\\"),
            _buildButton("*"),
            _buildButton("^"),
            _buildButton("<", insert: ">"),
            _buildButton(">", insert: "<"),
            _buildButton("#"),
            _buildButton("+"),
            _buildButton("-"),
            _buildButton("(", insert: ")"),
            _buildButton(")", insert: "("),
            _buildButton("_"),
            _buildButton("="),
            _buildButton(":"),
            _buildButton("'"),
            _buildButton('"'),
            _buildButton("↹", insert: "    "),
          ],
        ),
      ),
    );
  }
}
