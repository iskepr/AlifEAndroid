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
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 5, left: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('تشغيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5b3398),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.runAlifCode,
                ),
                Text(
                  'أدخل شفرة الف',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
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
                style: const TextStyle(
                  fontFamily: 'Cascadia Code',
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'اكتب كود لغة ألف هنا...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
