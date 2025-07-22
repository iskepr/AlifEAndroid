import 'package:flutter/material.dart';

class IDE extends StatefulWidget {
  const IDE({super.key, required this.controller, required this.runAlifCode});

  final TextEditingController controller;
  final VoidCallback runAlifCode;

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
        child: Row(
          children: [
            Expanded(
              flex: 15,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: IntrinsicWidth(
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: const InputDecoration.collapsed(
                      hintTextDirection: TextDirection.rtl,
                      hintText: 'اكتب شفرة لغة ألف هنا...',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey)),
                ),
                child: Text(
                  lineNumbers,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
