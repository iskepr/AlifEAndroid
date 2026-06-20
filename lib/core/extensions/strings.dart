import "dart:io";

import "../../constants.dart";

extension StringExtension on String {
  String get handelHomePath => replaceAll(kHomeDir, "~");

  String get getSafeDirCount {
  try {
    final dir = Directory(this);
    final count = dir.listSync().take(100).length;
    if (count == 0) return "مجلد فارغ";
    return count == 100 ? "+100 ملف" : "$count ملف";
  } catch (e) {
    return "مجلد محمي";
  }
}
}

extension IntExtension on int {
  String get formatFileSize {
    if (this < 1024) return "$this بايت";
    if (this < 1024 * 1024) {
      return "${(this / 1024).toStringAsFixed(2)} كيلوبايت";
    }
    if (this < 1024 * 1024 * 1024) {
      return "${(this / (1024 * 1024)).toStringAsFixed(2)} ميجابايت";
    }
    return "${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} جيجابايت";
  }
}
