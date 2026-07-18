import "package:flutter/material.dart";
import "package:vibration/vibration.dart";
import "../../constants.dart";
import "../helpers/hive_helper.dart";

enum AppSetting {
  fontSize,
  editorFont,
  autoSave,
  enableFolding,
  enableGuideLines,
  enableSuggestions,
  customKeyboard,
  lineWrap,
  tabSize,
  enableVibration,
  alifBinPath,
  gitBinPath,
}

extension AppSettingExt on AppSetting {
  String get key => name;

  dynamic get defaultValue {
    switch (this) {
      case AppSetting.fontSize:
        return kMediumFont;
      case AppSetting.editorFont:
        return kMainFont;
      case AppSetting.autoSave:
      case AppSetting.enableGuideLines:
      case AppSetting.enableVibration:
      case AppSetting.customKeyboard:
      case AppSetting.enableSuggestions:
        return true;
      case AppSetting.tabSize:
        return kCodeSpaceLength;
      case AppSetting.alifBinPath:
      case AppSetting.gitBinPath:
        return null;
      default:
        return false;
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  bool isReady = false;

  String get alifBinPath => get(AppSetting.alifBinPath);

  final Map<AppSetting, dynamic> _values = {};

  SettingsProvider() {
    for (var setting in AppSetting.values) {
      final value = HiveHelper.getData(kBoxSettings, setting.name);
      _values[setting] = value ?? setting.defaultValue;
    }
  }

  T get<T>(AppSetting setting) => (_values[setting] as T);

  void set(AppSetting setting, dynamic value) {
    if (_values[setting] == value) return;

    _values[setting] = value;

    if (value != null) {
      HiveHelper.saveData(kBoxSettings, key: setting.name, value);
    }

    notifyListeners();
  }

  // vibration
  void runVibration({required List<int> pattern, int duration = 0}) {
    if (!get<bool>(AppSetting.enableVibration)) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(pattern: pattern, duration: duration);
    });
  }
}
