import 'package:alifeditor/widgets/Settings.dart';
import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class About extends StatefulWidget {
  const About({super.key, required this.fontSize});
  final ValueNotifier<double> fontSize;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        height: 270,
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
            Settings(fontSize: widget.fontSize),
            Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.cpu, color: Colors.grey, size: 13),
                        SizedBox(width: 5),
                        Text(
                          "لغة ألف نـ5 النسخة 5.1.0",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.info, color: Colors.grey, size: 13),
                        SizedBox(width: 5),
                        Text(
                          "محرر طيف النسخة 1.0.0 (تجريبية)",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        LucideIcons.github,
                        color: Colors.grey,
                        size: 13,
                      ),
                      onPressed: () =>
                          _launchUrl("https://github.com/iskepr/AlifEAndroid"),
                      label: Text(
                        "الشفرة على جيت هاب",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        LucideIcons.earth,
                        color: Colors.grey,
                        size: 13,
                      ),
                      onPressed: () => _launchUrl("https://iskepr.github.io/"),
                      label: Text(
                        "تطـوير محـمـد ســكـيبر",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
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
