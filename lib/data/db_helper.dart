import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'my_table';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnDate = 'date';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId TEXT PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnUsername TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}





// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';
// // import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_sqlcipher/sqflite.dart';
// import 'password_item.dart';

// class _DBConfiguration {
//   final String path;
//   final String password;
//   final bool isAsset;

//   _DBConfiguration({
//     required this.path,
//     required this.password,
//     this.isAsset = false,
//   });

//   String get name => path.split("/").last;
// }

// class DBService {
//   late Database _database;
//   final _DBConfiguration _dbConf;

//   DBService({
//     required String name,
//     required String password,
//     bool isAsset = false,
//   }) : _dbConf = _DBConfiguration(
//           path: name,
//           password: password,
//           isAsset: isAsset,
//         );

//   Future<Database> get _db async => _database;

//   Future<Database> _initDatabase() async {
//     if (_dbConf.isAsset) {
//       await _copyAssetToLocal();
//     }
//     print("Database path: ${await getDatabasesPath()}");
//     _database = await openDatabase(
//       _dbConf.name,
//       password: _dbConf.password,
//       onCreate: DBService._onCreate,
//       version: 1,
//     );
//     return _database;
//   }

//   Future<void> _copyAssetToLocal() async {
//     final path =
//         "${await getDatabasesPath()}${Platform.pathSeparator}${_dbConf.name}";
//     if (!File(path).existsSync()) {
//       ByteData data = await rootBundle.load(_dbConf.path);
//       List<int> bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(path).writeAsBytes(bytes, flush: true, mode: FileMode.write);
//     }
//   }

//   static void _onCreate(Database db, int version) async {
//     await db.execute('''
//     CREATE TABLE credit_card (
//     id TEXT PRIMARY KEY, 
//     name TEXT NOT NULL,
//     username TEXT NOT NULL,
//     password TEXT NOT NULL,
//     date TEXT NOT NULL)
//     ''');
//   }

//   Future<int> insertSensitiveData(Password password) async {
//     final db = await _db;
//     return db.insert("password", password.attributes);
//   }

//   Future<List> allCards() async {
//     final db = await _db;
//     final cursor = await db.query("password");
//     return cursor.map((data) => Password.fromMap(data: data)).toList();
//   }
// }
