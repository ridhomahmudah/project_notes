import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 2; // Naikkan versi karena ada perubahan struktur
  static const String _tableName = "notes";
  static const String _catTable = "categories"; // Tabel baru untuk kategori

  static Future<void> initDb() async {
    if (_db != null) return;
    try {
      String _path = join(await getDatabasesPath(), 'notes.db');
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) async {
          // Buat tabel Catatan
          await db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT, note TEXT, date TEXT, "
            "category TEXT, " // Kolom baru agar catatan tahu kategorinya apa
            "imagePath TEXT)",
          );
          
          // Buat tabel Daftar Kategori
          await db.execute(
            "CREATE TABLE $_catTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "name TEXT UNIQUE)", // UNIQUE agar tidak ada nama ganda
          );

          // Masukkan kategori default
          await db.insert(_catTable, {'name': 'Semua'});
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Jika user update aplikasi, tambahkan kolom & tabel baru tanpa hapus data lama
            await db.execute("ALTER TABLE $_tableName ADD COLUMN category TEXT");
            await db.execute("CREATE TABLE $_catTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)");
            await db.insert(_catTable, {'name': 'Semua'});
          }
        },
      );
    } catch (e) {
      print("Error init DB: $e");
    }
  }

  // --- FUNGSI CATATAN ---
  static Future<int> insert(Map<String, dynamic> row) async {
    return await _db!.insert(_tableName, row);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName, orderBy: "id DESC");
  }

  static Future<int> delete(int id) async {
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // --- FUNGSI KATEGORI (Agar Permanen) ---
  
  // Ambil semua daftar kategori untuk ditampilkan di CategorySortBar
  static Future<List<Map<String, dynamic>>> getCategories() async {
    return await _db!.query(_catTable);
  }

  // Simpan kategori baru saat klik "Finish" di BottomSheet
  static Future<int> insertCategory(String name) async {
    return await _db!.insert(_catTable, {'name': name}, 
        conflictAlgorithm: ConflictAlgorithm.ignore); // Abaikan jika sudah ada
  }

  // Hapus kategori
  static Future<int> deleteCategory(String name) async {
    return await _db!.delete(_catTable, where: 'name = ?', whereArgs: [name]);
  }
}