import "package:flutter/material.dart";
import "../../constants.dart";

abstract class AppColors {
  static final Color primary = Colors.blueAccent.withOpacity(0.5);
  static final Color sacheme = Colors.purpleAccent.withOpacity(0.5);
  static const Color secondary = Colors.grey;
  static const Color foreground = Colors.white;
  static const Color background = Color(0xFF081433);

  static const Color error = Color(0xFFE9152D);
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
}

extension ThemeContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get primary => colorScheme.primary;
  Color get text => colorScheme.onBackground;
  Color get secondary => colorScheme.secondary;
  Color get third => colorScheme.surface;
  Color get border => colorScheme.outline;
  Color get shadow => colorScheme.shadow;
  Color get background => colorScheme.background;
  Color get foreground => colorScheme.surface;
  Color get error => colorScheme.error;
  Color get success => colorScheme.tertiary;
  Color get warning => AppColors.warning;
  Color get sacheme => AppColors.sacheme;
}

abstract class AppThemes {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.foreground,
      background: AppColors.background,
      onBackground: AppColors.foreground,
      outline: AppColors.secondary.withOpacity(0.3),
      error: AppColors.error,
      tertiary: AppColors.success,
    ),
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.compact,
    platform: TargetPlatform.linux,
    fontFamily: kMainFont,
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.foreground,
      background: AppColors.background,
      onBackground: AppColors.foreground,
      outline: AppColors.secondary.withOpacity(0.3),
      error: AppColors.error,
      tertiary: AppColors.success,
    ),
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.compact,
    platform: TargetPlatform.linux,
    fontFamily: kMainFont,
  );
}
