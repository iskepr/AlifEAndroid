import "../../../core/models/terminal_model.dart";

List getLineType(
  String text,
  LineType? type,
  bool? isError,
  String errorLabel,
  String warningLabel,
) {
  String prefix = "";
  LineType currentType = type ?? LineType.normal;

  final errorRegex = RegExp(r"(error|fail|خطا|خطأ|فشل)", caseSensitive: false);
  final warningRegex = RegExp(
    r"(warning|warn|alert|تحذير|تنبيه)",
    caseSensitive: false,
  );
  final successRegex = RegExp(
    r"(success|done|ok|نجاح| تم |موافق)",
    caseSensitive: false,
  );
  final infoRegex = RegExp(r"(info|note|معلومات|ملحوظة)", caseSensitive: false);

  if (type == LineType.error || isError == true || errorRegex.hasMatch(text)) {
    prefix = errorLabel;
    currentType = LineType.error;
  } else if (type == LineType.warning ||
      isError == false ||
      warningRegex.hasMatch(text)) {
    prefix = warningLabel;
    currentType = LineType.warning;
  } else if (successRegex.hasMatch(text)) {
    currentType = LineType.success;
  } else if (infoRegex.hasMatch(text)) {
    currentType = LineType.info;
  }

  return [prefix.isEmpty ? "" : "$prefix: ", currentType];
}
