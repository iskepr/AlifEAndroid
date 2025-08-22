import 'package:flutter/material.dart';

final keyWords = {
  "keywords": [
    "ك",
    "من",
    "مع",
    "هل",
    "اذا",
    "إذا",
    "مرر",
    "عدم",
    "ولد",
    "صنف",
    "احذف",
    "دالة",
    "لاجل",
    "لأجل",
    "والا",
    "وإلا",
    "توقف",
    "نطاق",
    "ارجع",
    "اواذا",
    "أوإذا",
    "بينما",
    "انتظر",
    "استمر",
    "مزامنة",
    "استورد",
    "حاول",
    "خلل",
    "نهاية",
  ],
  "keywords2": ["عام", "في"],
  "operators": [
    "=",
    "+",
    "-",
    "*",
    "\\",
    "\\\\",
    "\\^",
    "%",
    "==",
    "=+",
    "=-",
    "!=",
    "<",
    ">",
    "<=",
    ">=",
    "و",
    "او",
    "أو",
    "ليس",
  ],
  "strings": ['"', "'"],
  "numbers": [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "٠",
    "١",
    "٢",
    "٣",
    "٤",
    "٥",
    "٦",
    "٧",
    "٨",
    "٩",
  ],
  "booleans": ["صح", "خطأ", "خطا", "_تهيئة_", "هذا", "اصل"],
  "comments": ["#", "//"],
};

TextSpan colored(String t, Color c) => TextSpan(
  text: t,
  style: TextStyle(color: c),
);

List<TextSpan> alifHighlight(String text) {
  final spans = <TextSpan>[];
  int i = 0;

  bool isWordChar(String ch) =>
      RegExp(r'[a-zA-Z0-9_\u0600-\u06FF]').hasMatch(ch);

  while (i < text.length) {
    // النصوص
    for (var m in keyWords["strings"]!) {
      if (text.startsWith(m, i) || text.startsWith("م$m", i)) {
        bool isFormatted = text.startsWith("م$m", i);
        if (isFormatted) {
          spans.add(colored("م", Colors.white));
          i++;
        }
        int end = text.indexOf(m, i + 1);
        if (end == -1) {
          spans.add(colored(text.substring(i), Colors.green));
          break;
        }

        String s = text.substring(i, end + 1);

        if (isFormatted) {
          var matches = RegExp(r'\{([^}]+)\}').allMatches(s);
          if (matches.isEmpty) {
            spans.add(colored(s, Colors.green));
          } else {
            int pos = 0;
            for (var match in matches) {
              if (match.start > pos) {
                spans.add(colored(s.substring(pos, match.start), Colors.green));
              }
              spans.add(colored("{", Colors.white));
              spans.addAll(alifHighlight(match.group(1)!));
              spans.add(colored("}", Colors.white));
              pos = match.end;
            }
            if (pos < s.length) {
              spans.add(colored(s.substring(pos), Colors.green));
            }
          }
        } else {
          spans.add(colored(s, Colors.green));
        }

        i = end + 1;
        continue;
      }
    }

    // التعليقات
    if (text[i] == '#') {
      final end = text.indexOf('\n', i);
      spans.add(
        TextSpan(
          text: text.substring(i, end == -1 ? text.length : end),
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
      i = end == -1 ? text.length : end;
      continue;
    }

    // الدوال
    if (i + 1 < text.length && text[i] != ' ' && isWordChar(text[i])) {
      int end = i;
      while (end < text.length && isWordChar(text[end])) {
        end++;
      }
      if (end < text.length && text[end] == '(') {
        spans.add(colored(text.substring(i, end), Color(0xFFDAB744)));
        spans.add(colored('(', Colors.white));
        i = end + 1;
        continue;
      }
    }

    // الرمز التالي
    int next = text.length;
    for (int j = i; j < text.length; j++) {
      if (" \t\n(){}[];,#\"'".contains(text[j])) {
        next = j;
        break;
      }
    }
    if (next == i) {
      spans.add(colored(text[i], Colors.white));
      i++;
      continue;
    }

    final word = text.substring(i, next);

    // الأرقام
    final numMatch = RegExp(r'^\d+').firstMatch(word);
    if (numMatch != null) {
      spans.add(colored(numMatch.group(0)!, Color(0xFFc786c7)));
      if (numMatch.group(0)!.length < word.length) {
        spans.add(
          colored(word.substring(numMatch.group(0)!.length), Colors.white),
        );
      }
      i = next;
      continue;
    }

    // الكلمات المفتاحية و العلامات
    Color? color;
    for (var e in keyWords.entries) {
      if (e.key != "strings" && e.key != "comments" && e.value.contains(word)) {
        color = {
          "keywords": Colors.orange,
          "keywords2": Colors.red,
          "booleans": Color(0xFF7981e6),
          "operators": Color(0xFFe06c75),
          "numbers": Color(0xFFc786c7),
        }[e.key];
        break;
      }
    }

    spans.add(colored(word, color ?? Colors.white));
    i = next;
  }

  return spans;
}
