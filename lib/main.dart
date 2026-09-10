import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:provider/provider.dart";

import "constants.dart";
import "core/helpers/hive_helper.dart";
import "core/providers/settings_provider.dart";
import "core/providers/workspace_provider.dart";
import "core/theme/colors.dart";
import "features/editor/view/editor_view.dart";
import "features/keyboard/data/keyboard_provider.dart";
import "features/terminal/provider/terminal_provider.dart";
import "generated/l10n.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();
  await HiveHelper.init();

  runApp(
    MultiProvider(
      providers: [
        // Settings Provider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Workspace Provider
        ChangeNotifierProxyProvider<SettingsProvider, WorkspaceProvider>(
          create: (context) =>
              WorkspaceProvider(context.read<SettingsProvider>()),
          update: (context, settings, workspace) {
            if (workspace != null) return workspace;
            return WorkspaceProvider(settings);
          },
        ),

        // Terminal Provider - بياخد Settings و Workspace مع بعض
        ChangeNotifierProxyProvider2<
          SettingsProvider,
          WorkspaceProvider,
          TerminalProvider
        >(
          create: (context) => TerminalProvider(
            context.read<SettingsProvider>(),
            context.read<WorkspaceProvider>(),
          ),
          update: (context, settings, workspace, terminal) {
            final provider = terminal ?? TerminalProvider(settings, workspace);
            provider.updateWorkspace(workspace);
            return provider;
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
