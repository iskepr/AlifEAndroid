import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:url_launcher/url_launcher.dart";

import "../../../../constants.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/text.dart";

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          spacing: kMediumPadding,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.cpu,
                  color: context.secondary,
                  size: kSmallFont,
                ),
                const SizedBox(width: kSmallPadding),
                Text(
                  "${l10n.alifLangCore} $kAlifVersion",
                  style: ThemeText.smallG,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.info,
                  color: context.secondary,
                  size: kSoSmallFont,
                ),
                const SizedBox(width: kSmallPadding),
                Text(
                  "${l10n.ideVersion} $kAppVersion (${l10n.beta})",
                  style: ThemeText.smallG,
                ),
              ],
            ),
          ],
        ),
        Wrap(
          children: [
            TextButton.icon(
              icon: Icon(
                LucideIcons.gitMerge,
                color: context.secondary,
                size: 13,
              ),
              onPressed: () => _launchUrl("https://github.com/iskepr/TaifIDE"),
              label: const Text("الشفرة على جيت هاب", style: ThemeText.smallG),
            ),
            TextButton.icon(
              icon: Icon(LucideIcons.earth, color: context.secondary, size: 13),
              onPressed: () =>
                  _launchUrl("https://skepr.me/?from=TaifIDE"),
              label: const Text("تطـوير مُحمد سكيبر", style: ThemeText.smallG),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not launch $url");
  }
}
