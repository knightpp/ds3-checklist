import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager<T> {
  Database? db;
  T? checked;

  DatabaseManager(
    this.processChecked,
    this.type,
  )   : dbAssetPath = type.getAssetPath(),
        sqlQuery = type.getSqlQuery(),
        sqlUpdate = type.getSqlUpdate();

  final T Function(List<Map<String, dynamic>>) processChecked;
  final String dbAssetPath;
  final String sqlQuery;
  final String sqlUpdate;
  final DbFor type;

  Future<int> updateRecord(List params) async {
    return db!.rawUpdate(sqlUpdate, params);
  }

  static Future<void> resetDb(int magickNumber, DbFor type) async {
    if (magickNumber == 0xB16B00B5) {
      var db = await copyOrOpenDatabase(type.getAssetPath());
      await _copyAssetTo(type.getAssetPath(), db.path);
    } else {
      throw "boobs not found";
    }
  }

  Future<void> openDbAndParse() async {
    await _openDb().then((value) async => await _queryBuild());
    return;
  }

  Future<void> _queryBuild() async {
    if (checked == null) {
      print("(expensive) Quering database and building Map");
      final resp = await db!.rawQuery(sqlQuery);

      checked = await compute(
        processChecked,
        resp,
      );
    }
  }

  void reset() {
    db!.close();
    db = null;
    checked = null;
  }

  Future<void> _openDb() async {
    if (db == null) {
      db = await copyOrOpenDatabase(dbAssetPath);
    }
  }
}

Future<Database> copyOrOpenDatabase(String assetPath) async {
  final String dbPath = await _getWriteableDbPath(assetPath);
  if (!await File(dbPath).exists()) {
    // copy db from assets
    await _copyAssetTo(assetPath, dbPath);
  }
  return openDatabase(dbPath);
}

Future<void> _copyAssetTo(String assetPath, String destPath) async {
  final ByteData untouchedDb = await rootBundle.load(assetPath);
  final buffer = untouchedDb.buffer;
  await File(destPath).writeAsBytes(
      buffer.asUint8List(untouchedDb.offsetInBytes, untouchedDb.lengthInBytes),
      flush: true);
}

Future<String> _getWriteableDbPath(String assetPath) async {
  final String defaultPath = (await getApplicationDocumentsDirectory()).path;
  final String dbPath = join(defaultPath, basename(assetPath));
  return dbPath;
}

enum DbFor {
  Playthrough,
  Achievements,
  WeapsShields,
  Armor,
  Trades,
}

extension ToData on DbFor {
  String getAssetPath() {
    switch (this) {
      case DbFor.Playthrough:
        return "assets/sqlites/playthrough.sqlite";
      case DbFor.Achievements:
        return "assets/sqlites/achievements.sqlite";
      case DbFor.WeapsShields:
        return "assets/sqlites/weapons_and_shields.sqlite";
      case DbFor.Armor:
        return "assets/sqlites/armor.sqlite";
      case DbFor.Trades:
        return "assets/sqlites/trades.sqlite";
    }
  }

  String getSqlQuery() {
    switch (this) {
      case DbFor.Playthrough:
        return "select task_id, location_id, is_checked from pt_tasks ;";
      case DbFor.Achievements:
        return "select task_id, ach_id, is_checked from ach_tasks ;";
      case DbFor.WeapsShields:
        return "select task_id, cat_id, is_checked from ws_tasks ;";
      case DbFor.Armor:
        return "select task_id, cat_id, is_checked from armor_tasks ;";
      case DbFor.Trades:
        return "select trade_id, is_checked from trades ;";
    }
  }

  String getSqlUpdate() {
    switch (this) {
      case DbFor.Playthrough:
        return "update pt_tasks set is_checked = ?1 where task_id = ?2 and location_id = ?3";
      case DbFor.Achievements:
        return "update ach_tasks set is_checked = ?1 where task_id = ?2 and ach_id = ?3";
      case DbFor.WeapsShields:
        return "update ws_tasks set is_checked = ?1 where task_id = ?2 and cat_id = ?3";
      case DbFor.Armor:
        return "update armor_tasks set is_checked = ?1 where task_id = ?2 and cat_id = ?3";
      case DbFor.Trades:
        return "update trades set is_checked = ?1 where trade_id = ?2";
    }
  }
}
