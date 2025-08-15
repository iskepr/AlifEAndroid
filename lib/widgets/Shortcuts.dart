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
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2340),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: () => _insertText(insert ?? label),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081433),
        borderRadius: BorderRadius.circular(30),
      ),
      width: MediaQuery.of(context).size.width - 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
              _buildButton("(", insert: ")"),
              _buildButton(")", insert: "("),
              _buildButton("{", insert: "}"),
              _buildButton("}", insert: "{"),
              _buildButton("[", insert: "]"),
              _buildButton("]", insert: "["),
            ],
          ),
        ),
      ),
    );
  }
}
