import "package:hive_ce_flutter/hive_ce_flutter.dart";
import "package:path_provider/path_provider.dart";

import "../../constants.dart";
import "../models/data_typs.dart";

class HiveHelper {
  static const boxes = [kBoxOpenedFiles, kBoxSettings];

  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    await Hive.initFlutter("${dir.path}/hive");

    try {
      Hive.registerAdapter(FileEntityAdapter());
    } catch (_) {}

    await _openAllBoxes();
  }

  static Future<void> _openAllBoxes() async {
    for (var box in boxes) {
      await openBoxSafely(box);
    }
  }

  static Future<void> openBoxSafely(String boxName) async {
    try {
      await Hive.openBox(boxName);
    } catch (e) {
      if (e.toString().contains("unknown typeId") ||
          e.toString().contains("unsupported type")) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } catch (_) {}
        try {
          await Hive.openBox(boxName);
          return;
        } catch (_) {}
      }
      rethrow;
    }
  }

  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> clear() async {
    for (var boxName in boxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  }

  static Future<void> saveListData<T>(String boxName, List<T> data) async {
    final box = Hive.box(boxName);
    await box.clear();
    await box.addAll(data);
  }

  static List<T> getListData<T>(String boxName) {
    final box = Hive.box(boxName);
    if (box.isEmpty) return [];
    return box.values.cast<T>().toList();
  }

  static Future<void> saveData<T>(String boxName, T data, {String? key}) async {
    final box = Hive.box(boxName);
    await box.put(key ?? 0, data);
  }

  static T? getData<T>(String boxName, [String? key]) {
    final box = Hive.box(boxName);
    final data = box.get(key ?? 0);
    if (data == null) return null;
    return data as T;
  }

  static List<T> getListDataByKey<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data == null) return [];
    return List<T>.from(data);
  }

  static Future<void> saveListDataByKey<T>(
    String boxName,
    String key,
    List<T> data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  static T? getTDataByKey<T>(String boxName, [dynamic key]) {
    final box = Hive.box(boxName);
    final data = box.get(key ?? 0);
    if (data == null) return null;
    return data as T;
  }

  static Future<void> saveTDataByKey<T>(
    T data,
    String boxName, [
    dynamic key,
  ]) async {
    final box = Hive.box(boxName);
    await box.put(key ?? 0, data);
  }
}
