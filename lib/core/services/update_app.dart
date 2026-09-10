import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:ota_update/ota_update.dart";
import "package:package_info_plus/package_info_plus.dart";
import "../../constants.dart";
import "../theme/colors.dart";
import "../theme/text.dart";
import "../widgets/show_bottom_sheet.dart";

String repoName = "iskepr/TaifIDE";
String appName = "app.apk";

Future<void> checkUpdate(BuildContext context) async {
  try {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    final response = await http.get(
      Uri.parse("https://api.github.com/repos/$repoName/releases/latest"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final latestVersion = data["tag_name"];

      if (latestVersion != currentVersion) {
        if (!context.mounted) return;
        showMyBottomSheet(
          context: context,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(
                    LucideIcons.refreshCw,
                    size: 40,
                    color: context.foreground,
                  ),
                  Text(
                    "تحديث متاح",
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "يوجد تحديث جديد للتطبيق يُفضل تحديث المُحرر لتلقي المميزات الجديدة",
                    textAlign: TextAlign.center,
                    style: ThemeText.title,
                  ),
                ],
              ),
              Column(
                children: [
                  Text("من الاصدار $currentVersion إلى $latestVersion"),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        context.foreground,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _runOtaUpdate(
                        context,
                        "https://github.com/$repoName/releases/download/$latestVersion/$appName",
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "تحديث وتثبيت",
                          style: TextStyle(
                            color: context.background,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const IntrinsicWidth(
                      stepWidth: double.infinity,
                      child: Center(
                        child: Text("ليس الأن", style: ThemeText.title),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    debugPrint("حديث ${l10n.error}: $e");
  }
}

void _runOtaUpdate(BuildContext context, String url) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String statusText = "جاري الاتصال...";
      double progressValue = 0.0;

      return StatefulBuilder(
        builder: (context, setState) {
          if (progressValue == 0.0 && statusText == "جاري الاتصال...") {
            try {
              OtaUpdate()
                  .execute(url, destinationFilename: appName)
                  .listen(
                    (OtaEvent event) {
                      setState(() {
                        if (event.status == OtaStatus.DOWNLOADING) {
                          statusText = "جاري التحميل: ${event.value}%";
                          progressValue =
                              (int.tryParse(event.value ?? "0") ?? 0) / 100;
                        } else if (event.status == OtaStatus.INSTALLING) {
                          statusText = "جاري التثبيت...";
                          progressValue = 1.0;
                          Navigator.pop(context);
                        } else {
                          statusText = event.status.toString();
                        }
                      });
                    },
                    onError: (e) {
                      setState(() {
                        statusText = "فشل التحميل: $e";
                      });
                      Future.delayed(const Duration(seconds: 3), () {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
                  );
            } catch (e) {
              debugPrint("فشل التحميل: $e");
              Navigator.pop(context);
            }
          }

          return AlertDialog(
            title: const Text("تحديث التطبيق"),
            content: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusText),
                LinearProgressIndicator(value: progressValue),
              ],
            ),
          );
        },
      );
    },
  );
}
