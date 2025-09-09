import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenedFiles extends StatefulWidget {
  const OpenedFiles({
    super.key,
    required this.currentFilePath,
    required this.currentCode,
    required this.output,
    required this.selectedFile,
    this.onFileSelected,
  });

  final ValueNotifier<String?> currentFilePath;
  final TextEditingController currentCode;
  final ValueNotifier<String> output;
  final int selectedFile;
  final ValueChanged<int>? onFileSelected;

  @override
  OpenedFilesState createState() => OpenedFilesState();
}

class OpenedFilesState extends State<OpenedFiles> {
  late int _selectedIndex;
  List<Map<String, String>> files = [];
  bool _isLoading = true;

  Timer? _autoSaveTimer;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedFile;
    // متابعة أي تعديل على الشفرة
    widget.currentCode.addListener(() {
      _hasChanges = true;
    });
    _startAutoSave();
    _loadFilesFromStorage();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hasChanges && _selectedIndex >= 0 && _selectedIndex < files.length) {
        files[_selectedIndex]["Code"] = widget.currentCode.text;
        _saveFilesToStorage();
        _hasChanges = false;
      }
    });
  }

  Future<void> _saveFilesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(files);
    await prefs.setString('opened_files', encoded);
  }

  void _openFile(int fileIndex) async {
    if (fileIndex < 0 || fileIndex >= files.length) return;
    final prefs = await SharedPreferences.getInstance();

    // حفظ الملف الحالي
    if (_selectedIndex >= 0 && _selectedIndex < files.length) {
      try {
        files[_selectedIndex]["Code"] = widget.currentCode.text;
        await _saveFilesToStorage();
      } catch (e) {
        widget.output.value += "خطأ أثناء حفظ الملف الحالي: $e\n";
      }
    }

    // تغيير المؤشر قبل الـ setState
    _selectedIndex = fileIndex;
    await prefs.setInt("last_file", fileIndex);

    final selectedFile = files[fileIndex];
    widget.currentCode.clear();
    widget.currentFilePath.value = selectedFile["Path"] ?? "";

    setState(() {});

    // القرائة من الملف
    // if (selectedFile["Path"] != null && selectedFile["Path"]!.isNotEmpty) {
    //   try {
    //     final file = File(selectedFile["Path"]!);
    //     if (await file.exists()) {
    //       final code = await file.readAsString();

    //       widget.currentCode.text = code;
    //       selectedFile["Code"] = code;
    //     } else {
    //       widget.currentCode.text = selectedFile["Code"] ?? "";
    //     }
    //   } catch (e) {
    //     widget.output.value += "خطأ أثناء فتح الملف: $e\n";
    //     widget.currentCode.text = selectedFile["Code"] ?? "";
    //   }
    // } else {}
    widget.currentCode.text = selectedFile["Code"] ?? "";

    await _saveFilesToStorage();

    if (widget.onFileSelected != null) {
      widget.onFileSelected!(fileIndex);
    }
  }

  Future<void> _loadFilesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // عرض الملفات المفتوحة سابقا
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
    } else {
      createFile(
        name: "الأعداد_الاولية.الف",
        code: """
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
      );
    }

    final lastFile = prefs.getInt("last_file");
    if (lastFile != null && lastFile < files.length) {
      _openFile(lastFile);
    }
    setState(() => _isLoading = false);
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

  @override
  void didUpdateWidget(OpenedFiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFile != _selectedIndex) {
      _selectedIndex = widget.selectedFile;
    }
  }

  void createFile({String name = "", String code = ""}) {
    final newFile = {
      "Name": name.isEmpty ? "ملف_جديد_${files.length + 1}.الف" : name,
      "Path": "",
      "Code": code,
    };
    setState(() {
      files.add(newFile);
      _selectedIndex = files.length - 1;
      widget.currentFilePath.value = "";
      widget.currentCode.text = newFile["Code"] ?? "";
    });
    _saveFilesToStorage();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
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
                  createFile();
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
