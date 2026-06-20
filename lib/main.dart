import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "constants.dart";
import "core/providers/settings_provider.dart";
import "features/terminal/provider/terminal_provider.dart";
import "core/providers/workspace_provider.dart";
import "core/theme/colors.dart";
import "features/editor/view/editor_view.dart";
import "features/keyboard/data/keyboard_provider.dart";
import "generated/l10n.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await RustLib.init();

  runApp(
    MultiProvider(
      providers: [
        // Settings Provider
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        // Workspace Provider
        ChangeNotifierProxyProvider<SettingsProvider, WorkspaceProvider>(
          create: (context) =>
              WorkspaceProvider(context.read<SettingsProvider>()),
          update: (context, settings, workspace) {
            if (workspace != null) return workspace;
            return WorkspaceProvider(settings);
          },
        ),
        // Terminal Provider
        ChangeNotifierProxyProvider<SettingsProvider, TerminalProvider>(
          create: (context) =>
              TerminalProvider(context.read<SettingsProvider>()),
          update: (context, settings, terminal) {
            if (terminal != null) return terminal;
            return TerminalProvider(settings);
          },
        ),
        // Shortcuts Provider
        ChangeNotifierProvider(create: (_) => ShortcutsProvider()),
      ],
      child: const Taif(),
    ),
  );
}

class Taif extends StatelessWidget {
  const Taif({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => S.of(context).title,

      // لغة التطبيق
      locale: const Locale("ar"),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // الوان التطبيق
      themeMode: ThemeMode.dark,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,

      home: const EditorView(),
    );
  }
}
