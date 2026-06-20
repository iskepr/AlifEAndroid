import "package:code_forge/code_forge.dart";
import "package:flutter/material.dart";
import "../../editor/models/key_entity.dart";

class ShortcutsProvider extends ChangeNotifier {
  static final List<KeyEntity> nums = [
    KeyEntity(name: "0", insert: "(", closing: ")"),
    KeyEntity(name: "9", insert: ")"),
    KeyEntity(name: "8", insert: "*"),
    KeyEntity(name: "7", insert: "&"),
    KeyEntity(name: "6", insert: "^"),
    KeyEntity(name: "5", insert: "%"),
    KeyEntity(name: "4", insert: "\$"),
    KeyEntity(name: "3", insert: "#"),
    KeyEntity(name: "2", insert: "@"),
    KeyEntity(name: "1", insert: "!"),
  ];

  static final List<List<SymbolData>> symbolsTemplate = [
    [
      SymbolData("[", closing: "]"),
      SymbolData("]"),
      SymbolData("{", closing: "}"),
      SymbolData("}"),
      SymbolData("|"),
      SymbolData("\\"),
      SymbolData("/"),
      SymbolData("~"),
      SymbolData("`", closing: "`"),
      SymbolData("=="),
      SymbolData("+"),
    ],
    [
      SymbolData("'", closing: "'"),
      SymbolData('"', closing: '"'),
      SymbolData(":"),
      SymbolData(";"),
      SymbolData("_"),
      SymbolData("="),
      SymbolData("!="),
      SymbolData("&&"),
      SymbolData("||"),
      SymbolData(""),
      SymbolData("?"),
    ],
    [
      SymbolData("-"),
      SymbolData(","),
      SymbolData("<"),
      SymbolData(">"),
      SymbolData("!"),
      SymbolData("؟"),
      SymbolData("%"),
      SymbolData("#"),
      SymbolData("@"),
      SymbolData("\$"),
    ],
  ];

  static const List<List<String>> arabicNames = [
    ["ج", "ح", "خ", "ه", "ع", "غ", "ف", "ق", "ث", "ص", "ض"],
    ["ط", "ك", "م", "ن", "ت", "ا", "ل", "ب", "ي", "س", "ش"],
    ["د", "ظ", "ز", "و", "ة", "ى", "ر", "ؤ", "ء", "ذ"],
  ];

  static const List<List<String>> englishNames = [
    ["p", "o", "i", "u", "y", "t", "r", "e", "w", "q"],
    ["l", "k", "j", "h", "g", "f", "d", "s", "a"],
    ["m", "n", "b", "v", "c", "x", "z"],
  ];

  static List<List<KeyEntity>> buildLayout(
    List<List<String>> names,
    List<List<SymbolData>> templates,
  ) {
    return List.generate(names.length, (rowIndex) {
      return List.generate(names[rowIndex].length, (charIndex) {
        final hasSymbol = charIndex < templates[rowIndex].length;
        final symbol = hasSymbol ? templates[rowIndex][charIndex] : null;

        return KeyEntity(
          name: names[rowIndex][charIndex],
          insert: symbol?.insert ?? names[rowIndex][charIndex],
          closing: symbol?.closing,
        );
      });
    });
  }

  static List<List<KeyEntity>> get arabicLayout =>
      buildLayout(arabicNames, symbolsTemplate);
  static List<List<KeyEntity>> get englishLayout =>
      buildLayout(englishNames, symbolsTemplate);

  void moveCursorHorizontal(CodeForgeController controller, int direction) {
    final int newOffset = controller.selection.baseOffset - direction;
    if (newOffset >= 0 && newOffset <= controller.text.length) {
      controller.selection = TextSelection.collapsed(offset: newOffset);
    }
  }

  void moveCursorVertical(CodeForgeController controller, int direction) {
    final offset = controller.selection.extentOffset;
    final int currentLine = controller.getLineAtOffset(offset);
    final int targetLine = (currentLine + direction).clamp(
      0,
      controller.lineCount - 1,
    );

    if (targetLine == currentLine) return;

    final int lineStart = controller.getLineStartOffset(currentLine);
    final int column = offset - lineStart;

    final int targetLineStart = controller.getLineStartOffset(targetLine);
    final String targetLineText = controller.getLineText(targetLine);

    final int newColumn = column.clamp(0, targetLineText.length);
    controller.selection = TextSelection.collapsed(
      offset: targetLineStart + newColumn,
    );
  }
}
