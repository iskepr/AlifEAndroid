import 'package:flutter/material.dart';

final Map<String, List<String>> keyWords = {
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
  "strings": ["\"", "'"],
  "numbers": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
  "booleans": ["صح", "خطأ", "خطا", "_تهيئة_", "هذا", "اصل"],
  "comments": ["#", "//"],
};

List<TextSpan> alifHighlight(String text) {
  List<TextSpan> spans = [];
  int i = 0;

  while (i < text.length) {
    bool foundString = false;
    String? mark;
    for (var m in keyWords["strings"]!) {
      if (text.startsWith(m, i)) {
        foundString = true;
        mark = m;
        break;
      }
    }

    if (foundString) {
      int end = text.indexOf(mark!, i + 1);
      if (end == -1) {
        spans.add(
          TextSpan(
            text: text.substring(i),
            style: TextStyle(color: Colors.green),
          ),
        );
        break;
      }

      String s = text.substring(i, end + 1);
      var matches = RegExp(r'\{([^}]+)\}').allMatches(s).toList();
      if (matches.isEmpty) {
        spans.add(
          TextSpan(
            text: s,
            style: TextStyle(color: Colors.green),
          ),
        );
      } else {
        int pos = 0;
        for (var m in matches) {
          if (m.start > pos) {
            spans.add(
              TextSpan(
                text: s.substring(pos, m.start),
                style: TextStyle(color: Colors.green),
              ),
            );
          }
          spans.add(
            TextSpan(
              text: '{',
              style: TextStyle(color: Colors.white),
            ),
          );
          spans.add(TextSpan(children: alifHighlight(m.group(1)!)));
          spans.add(
            TextSpan(
              text: '}',
              style: TextStyle(color: Colors.white),
            ),
          );
          pos = m.end;
        }
        if (pos < s.length) {
          spans.add(
            TextSpan(
              text: s.substring(pos),
              style: TextStyle(color: Colors.green),
            ),
          );
        }
      }
      i = end + 1;
      continue;
    }

    if (text[i] == '#') {
      int end = text.indexOf('\n', i);
      if (end == -1) end = text.length;
      spans.add(
        TextSpan(
          text: text.substring(i, end),
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
      i = end;
      continue;
    }

    if (i + 1 < text.length &&
        text[i] != ' ' &&
        RegExp(r'[a-zA-Z0-9_\u0600-\u06FF]').hasMatch(text[i])) {
      int end = i;
      while (end < text.length &&
          RegExp(r'[a-zA-Z0-9_\u0600-\u06FF]').hasMatch(text[end])) {
        end++;
      }

      if (end < text.length && text[end] == '(') {
        spans.add(
          TextSpan(
            text: text.substring(i, end),
            style: TextStyle(color: Color(0xFFDAB744)),
          ),
        );
        spans.add(
          TextSpan(
            text: '(',
            style: TextStyle(color: Colors.white),
          ),
        );
        i = end + 1;
        continue;
      }
    }

    int next = text.length;
    for (int j = i; j < text.length; j++) {
      if (" \t\n(){}[];,#\"'".contains(text[j])) {
        next = j;
        break;
      }
    }

    if (next == i) {
      spans.add(
        TextSpan(
          text: text[i],
          style: TextStyle(color: Colors.white),
        ),
      );
      i++;
      continue;
    }

    String word = text.substring(i, next);
    var num = RegExp(r'^\d+').firstMatch(word);
    if (num != null) {
      spans.add(
        TextSpan(
          text: num.group(0),
          style: TextStyle(color: Color(0xFFc786c7)),
        ),
      );
      if (num.group(0)!.length < word.length) {
        spans.add(
          TextSpan(
            text: word.substring(num.group(0)!.length),
            style: TextStyle(color: Colors.white),
          ),
        );
      }
      i = next;
      continue;
    }

    Color? color;
    for (var e in keyWords.entries) {
      if (e.key != "strings" && e.key != "comments" && e.value.contains(word)) {
        switch (e.key) {
          case "keywords":
            color = Colors.orange;
            break;
          case "keywords2":
            color = Colors.red;
            break;
          case "booleans":
            color = Color(0xFF7981e6);
            break;
          case "operators":
            color = Color(0xFFe06c75);
            break;
          case "numbers":
            color = Color(0xFFc786c7);
            break;
        }
        break;
      }
    }

    spans.add(
      TextSpan(
        text: word,
        style: TextStyle(color: color ?? Colors.white),
      ),
    );
    i = next;
  }

  return spans;
}
