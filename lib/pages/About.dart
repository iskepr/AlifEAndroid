import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        height: 190,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0830),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "محرر طيف النسخة 1.0.0 (تجريبية)",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(LucideIcons.info, color: Colors.white, size: 20),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "لغة الف نـ5 النسخة 5.1.0",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(LucideIcons.cpu, color: Colors.white, size: 20),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _launchUrl("https://github.com/iskepr/AlifEAndroid"),
                      child: Text(
                        "الشفرة على جيت هاب",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Icon(LucideIcons.github, color: Colors.white, size: 18),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _launchUrl("https://iskepr.github.io/"),
                      child: Text(
                        "تطـوير محـمـد ســكـيبر",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Icon(LucideIcons.earth, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
