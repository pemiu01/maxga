import 'package:maxga/database/mangaData.repo.dart';
import 'package:maxga/database/readMangaStatus.repo.dart';
import 'package:sqflite/sqflite.dart';

import 'database-value.dart';

class MaxgaDatabaseInitializr {
  static Future<void> initDataBase() async {
    final databasePath = await getDatabasesPath();
    Database database;
    try {
      database = await openDatabase(
        '$databasePath/$MaxgaDataBaseName.db',
        version: 1,
        onCreate: (db, version) => MaxgaDatabaseInitializr._onCreate(db, version),
        onUpgrade: (db, oldVersion, newVersion) =>
            MaxgaDatabaseInitializr._onUpdate(db, oldVersion),
      );
      final test = await MangaDataRepository.findAll(database: database);
      print(test.length);
      print('database init success');
    } catch (e) {
      print(e);
    } finally {
      database.close();
    }
  }

  static _onUpdate(Database database, int oldVersion) {
    switch (oldVersion) {
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    switch (version) {
      case 1:
        await _MaxgaDataBaseFirstVersionHelper.initTable(db);
        break;
    }
  }
}
class _MaxgaDataBaseFirstVersionHelper {
  static initTable(Database db) async {
    await db.execute('create table manga ('
        'sourceKey text,'
        'authors text,'
        'id integer,'
        'infoUrl text,'
        'status text,'
        'coverImgUrl text,'
        'title text,'
        'introduce text,'
        'typeList text,'
        'hasUpdate integer,'
        'chapterList text'
        ');');

    await db.execute('create table manga_read_status ('
        'infoUrl text,'
        'isCollect INTEGER,'
        'lastReadDate TEXT,'
        'readImageIndex integer,'
        'readChapterId integer'
        ');');
  }
}