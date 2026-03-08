import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 3; // Gunakan versi terbaru 3
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
          // Buat tabel Catatan dengan skema versi 3 (Lengkap)
          await db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT, "
            "note TEXT, "
            "date TEXT, "
            "category TEXT, " 
            "imagePath TEXT, "
            "color INTEGER, "
            "attachedIds TEXT)", 
          );

          // Buat tabel Daftar Kategori
          await db.execute(
            "CREATE TABLE $_catTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT UNIQUE)",
          );

          // Masukkan kategori default
          await db.insert(_catTable, {'name': 'Semua'});
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Migrasi dari v1 ke v2 (Tambah Kategori)
          if (oldVersion < 2) {
            await db.execute("ALTER TABLE $_tableName ADD COLUMN category TEXT");
            await db.execute("CREATE TABLE $_catTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)");
            await db.insert(_catTable, {'name': 'Semua'});
          }
          // Migrasi dari v2 ke v3 (Tambah attachedIds dan color)
          if (oldVersion < 3) {
            var tableInfo = await db.rawQuery("PRAGMA table_info($_tableName)");
            
            // Cek & Tambah attachedIds
            bool hasAttachedIds = tableInfo.any((column) => column['name'] == 'attachedIds');
            if (!hasAttachedIds) {
              await db.execute("ALTER TABLE $_tableName ADD COLUMN attachedIds TEXT");
            }

            // Cek & Tambah color
            bool hasColor = tableInfo.any((column) => column['name'] == 'color');
            if (!hasColor) {
              await db.execute("ALTER TABLE $_tableName ADD COLUMN color INTEGER");
            }
          }
        },
      );
      print("Database initialized successfully");
    } catch (e) {
      print("Error init DB: $e");
    }
  }

  // --- FUNGSI CATATAN (CRUD) ---

  static Future<int> insert(Map<String, dynamic> row) async {
    return await _db!.insert(
      _tableName, 
      row, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName, orderBy: "id DESC");
  }

  // Di dalam DBHelper.dart
static Future<int> update(Map<String, dynamic> note) async {
  return await _db!.update(
    _tableName,
    note, // Pastikan map 'note' ini berisi key 'color'
    where: 'id = ?',
    whereArgs: [note['id']],
  );
}

  static Future<int> delete(int id) async {
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // --- FUNGSI KATEGORI ---

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

  static Future<int> deleteCategory(String name) async {
    return await _db!.delete(_catTable, where: 'name = ?', whereArgs: [name]);
  }

  // Update kategori pada catatan tertentu
  static Future<int> updateNoteCategory(int id, String categoryName) async {
    return await _db!.update(
      _tableName,
      {'category': categoryName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
}