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
    return SizedBox(
      width: 25,
      height: 30,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () => _insertText(insert ?? label),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081433),
        borderRadius: BorderRadius.circular(30),
      ),
      width: MediaQuery.of(context).size.width - 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildButton("↹", insert: "    "),
            _buildButton("\""),
            _buildButton("'"),
            _buildButton(":"),
            _buildButton(","),
            _buildButton("+"),
            _buildButton("-"),
            _buildButton("\\"),
            _buildButton("*"),
            _buildButton("_"),
            _buildButton("="),
            _buildButton("^"),
            _buildButton("⏎", insert: "/س"),
            _buildButton("("),
            _buildButton(")"),
            _buildButton("{"),
            _buildButton("}"),
            _buildButton("["),
            _buildButton("]"),
          ],
        ),
      ),
    );
  }
}
