import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenedFiles extends StatefulWidget {
  const OpenedFiles({
    super.key,
    required this.currentFilePath,
    required this.currentCode,
    required this.output,
  });

  final ValueNotifier<String?> currentFilePath;
  final TextEditingController currentCode;
  final ValueNotifier<String> output;

  @override
  OpenedFilesState createState() => OpenedFilesState();
}

class OpenedFilesState extends State<OpenedFiles> {
  int _selectedIndex = 0;
  List<Map<String, String>> files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilesFromStorage();
  }

  Future<void> _loadFilesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // لو دي أول مرة يفتح التطبيق
    final isFirstRun = prefs.getBool('is_first_run') ?? true;

    if (isFirstRun) {
      files = [
        {
          "Name": "الأعداد_الاولية.الف",
          "Path": "",
          "Code": """
# هذا البرنامج يقوم بطباعة الأعداد الاولية ضمن المدى المعطى له
دالة هل_اولي(عدد):
    اذا عدد < 2:
        ارجع
    اذا عدد == 2:
        اطبع(عدد)
        ارجع
    اذا ليس عدد \\\\ 2:
        ارجع
    لاجل مقسوم في مدى(3, صحيح(\\^عدد) + 1, 2):
        اذا ليس عدد \\\\ مقسوم:
            ارجع
    اطبع(عدد)

اطبع("*- هذا البرنامج يقوم بإيجاد الأعداد الأولية ضمن المدى المدخل له -*")
ن = صحيح(ادخل("ادخل عدد: "))
لاجل ب في مدى(ن):
    هل_اولي(ب)
اطبع(م"تم إيجاد الاعداد الاولية ضمن العدد { ن }")
""",
        },
      ];
      await _saveFilesToStorage();
      await prefs.setBool('is_first_run', false); // علم إنه مش أول مرة خلاص
    } else {
      // حمل الملفات العادية
      final savedFiles = prefs.getString('opened_files');
      if (savedFiles != null) {
        try {
          final decoded = jsonDecode(savedFiles);
          if (decoded is List) {
            files = decoded.map<Map<String, String>>((item) {
              return {
                "Name": item["Name"].toString(),
                "Path": item["Path"].toString(),
                "Code": item["Code"].toString(),
              };
            }).toList();
          }
        } catch (e) {
          print("خطأ في قراءة البيانات المخزنة: $e");
        }
      }
    }
    if (files.isNotEmpty) {
      _openFile(0);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveFilesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('opened_files', jsonEncode(files));
  }

  void addOrUpdateFile(Map<String, String> file) {
    final existingIndex = files.indexWhere((f) => f['Path'] == file['Path']);
    setState(() {
      if (existingIndex >= 0) {
        files[existingIndex] = file;
      } else {
        files.add(file);
      }
    });
    _saveFilesToStorage();
  }

  void _openFile(int fileIndex) async {
    if (fileIndex < 0 || fileIndex >= files.length) return;

    // حفظ الملف الحالي قبل التبديل
    if (_selectedIndex >= 0 && _selectedIndex < files.length) {
      final currentFilePath = files[_selectedIndex]["Path"];
      if (currentFilePath != null && currentFilePath.isNotEmpty) {
        try {
          final currentFile = File(currentFilePath);
          await currentFile.writeAsString(widget.currentCode.text);
          files[_selectedIndex]["Code"] = widget.currentCode.text;
        } catch (e) {
          widget.output.value += "خطأ أثناء حفظ الملف الحالي: $e\n";
        }
      }
    }

    // فتح الملف الجديد
    setState(() {
      _selectedIndex = fileIndex;
      widget.currentFilePath.value = files[fileIndex]["Path"] ?? "";
      widget.currentCode.text = files[fileIndex]["Code"] ?? "";
    });

    if (files[fileIndex]["Path"] != null &&
        files[fileIndex]["Path"]!.isNotEmpty) {
      try {
        final file = File(files[fileIndex]["Path"]!);
        if (await file.exists()) {
          final code = await file.readAsString();
          setState(() {
            widget.currentCode.text = code;
            files[fileIndex]["Code"] = code;
          });
        }
      } catch (e) {
        widget.output.value += "خطأ أثناء فتح الملف: $e\n";
      }
    }
    _saveFilesToStorage();
  }

  @override
  void dispose() {
    _saveFilesToStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            "جاري تحميل الملفات...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: files.length + 1,
        itemBuilder: (context, i) {
          if (i == files.length) {
            // زر انشاء ملف جديد
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  final newFile = {
                    "Name": "ملف_جديد_${files.length + 1}.الف",
                    "Path": "",
                    "Code": "",
                  };
                  setState(() {
                    files.add(newFile);
                    _selectedIndex = files.length - 1;
                    widget.currentFilePath.value = "";
                    widget.currentCode.clear();
                  });
                  _saveFilesToStorage();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            );
          }
          final sel = _selectedIndex == i;
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: sel ? Border.all(color: const Color(0x509F45D3)) : null,
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: sel ? const Color(0x10FFFFFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _openFile(i),
                onLongPress: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        backgroundColor: const Color(0xFF081433),
                        title: Text(
                          'تأكيد الحذف',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'هل أنت متأكد من حذف الملف "${files[i]["Name"]}"؟',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('لا'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('نعم'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (confirmed == true) {
                    setState(() {
                      files.removeAt(i);
                      if (_selectedIndex == i) {
                        if (files.isNotEmpty) {
                          _selectedIndex = 0;
                          widget.currentFilePath.value = files[0]["Path"] ?? "";
                          widget.currentCode.text = files[0]["Code"] ?? "";
                        } else {
                          _selectedIndex = -1;
                          widget.currentFilePath.value = null;
                          widget.currentCode.clear();
                        }
                      } else if (_selectedIndex > i) {
                        _selectedIndex--;
                      }
                    });

                    await _saveFilesToStorage();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    files[i]["Name"]!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
