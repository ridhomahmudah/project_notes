import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = "notes";

  static Future<void> initDb() async {
    if (_db != null) return;
    try {
      String _path = await getDatabasesPath() + 'notes.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("Membuat tabel baru...");
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "imagePath TEXT)", 
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // Fungsi Simpan Catatan
  static Future<int> insert(Map<String, dynamic> row) async {
    return await _db!.insert(_tableName, row);
  }

  // Fungsi Ambil Semua Catatan
  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName);
  }
}