import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool enableSyntaxHighlighting = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getBool('enable_syntax_highlighting');
    setState(() {
      enableSyntaxHighlighting = savedSettings ?? false;
    });
  }

  void saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_syntax_highlighting', value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height / 1.2,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0830),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.settings, size: 22, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'الإعدادات',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Color(0x11FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Icon(
                        LucideIcons.text,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'حقل الادخال',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Switch(
                      value: enableSyntaxHighlighting,
                      onChanged: (value) {
                        setState(() {
                          enableSyntaxHighlighting = value;
                        });
                        saveSettings(value);
                      },
                    ),
                    Text(
                      "تفعيل التلوين (تجريبي)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
