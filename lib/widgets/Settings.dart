import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.fontSize});
  final ValueNotifier<double> fontSize;
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.settings, color: Colors.white, size: 25),
            SizedBox(width: 5),
            Text(
              "الإعدادات",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InputQty(
                    initVal: widget.fontSize.value,
                    maxVal: 50,
                    minVal: 10,
                    steps: 1,
                    qtyFormProps: QtyFormProps(
                      style: TextStyle(color: Colors.white),
                      enableTyping: false,
                    ),
                    decoration: QtyDecorationProps(border: InputBorder.none),
                    onQtyChanged: (val) async {
                      double newSize;
                      if (val is num) {
                        newSize = val.toDouble();
                      } else {
                        final parsed = double.tryParse(val.toString());
                        if (parsed == null) return;
                        newSize = parsed;
                      }
                      widget.fontSize.value = newSize;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble('EditorFontSize', newSize);
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        "(15)",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "حجم الخط",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
