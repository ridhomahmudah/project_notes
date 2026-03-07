import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 3; // Naikkan ke versi 3
  static const String _tableName = "notes";
  static const String _catTable = "categories";

  static Future<void> initDb() async {
    if (_db != null) return;
    try {
      String _path = join(await getDatabasesPath(), 'notes.db');
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) async {
          // Buat tabel Catatan dengan skema LENGKAP
          await db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT, "
            "note TEXT, "
            "date TEXT, "
            "category TEXT, " 
            "imagePath TEXT, "
            "color INTEGER, "
            "attachedIds TEXT)", // Tambahkan kolom ini
          );

          // Buat tabel Daftar Kategori
          await db.execute(
            "CREATE TABLE $_catTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT UNIQUE)",
          );

          await db.insert(_catTable, {'name': 'Semua'});
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Migrasi jika user datang dari versi 1 ke 2
          if (oldVersion < 2) {
            await db.execute("ALTER TABLE $_tableName ADD COLUMN category TEXT");
            await db.execute("CREATE TABLE $_catTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)");
            await db.insert(_catTable, {'name': 'Semua'});
          }
          // Migrasi jika user datang dari versi 2 ke 3 (Menambahkan attachedIds)
          if (oldVersion < 3) {
            // Cek apakah kolom sudah ada untuk menghindari error jika user uninstall/reinstall
            var tableInfo = await db.rawQuery("PRAGMA table_info($_tableName)");
            var hasAttachedIds = tableInfo.any((column) => column['name'] == 'attachedIds');
            
            if (!hasAttachedIds) {
              await db.execute("ALTER TABLE $_tableName ADD COLUMN attachedIds TEXT");
            }
          }
        },
      );
    } catch (e) {
      print("Error init DB: $e");
    }
  }

  // --- Operasi CRUD (Tetap Sama) ---

  static Future<int> insert(Map<String, dynamic> row) async {
    print("Insert ke DB...");
    return await _db!.insert(
      _tableName, 
      row, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName, orderBy: "id DESC");
  }

  static Future<int> delete(int id) async {
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Map<String, dynamic> row) async {
    return await _db!.update(
      _tableName, 
      row, 
      where: 'id = ?', 
      whereArgs: [row['id']]
    );
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    return await _db!.query(_catTable);
  }

  static Future<int> insertCategory(String name) async {
    return await _db!.insert(
      _catTable, 
      {'name': name}, 
      conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }

  static Future<int> updateNoteCategory(int id, String categoryName) async {
    return await _db!.update(
      _tableName,
      {'category': categoryName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCategory(String name) async {
    return await _db!.delete(_catTable, where: 'name = ?', whereArgs: [name]);
  }

  static Future<int> update(int id, Map<String, dynamic> row) async {
    return await _db!.update(
      _tableName,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}