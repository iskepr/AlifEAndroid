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
    return Container(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
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
      ),
    );
  }
}
