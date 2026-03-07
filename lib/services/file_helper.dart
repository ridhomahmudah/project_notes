import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileHelper {
  static Future<void> downloadNoteAsZip({
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      final encoder = ZipFileEncoder();
      final directory = await getTemporaryDirectory();
      final zipPath = '${directory.path}/$title.zip';
      
      encoder.create(zipPath);

      // 1. Tambahkan Konten Teks (File .txt)
      final textFile = File('${directory.path}/note_content.txt');
      await textFile.writeAsString("Judul: $title\n\n$content");
      encoder.addFile(textFile);

      // 2. Tambahkan Gambar jika ada
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          encoder.addFile(imageFile);
        }
      }

      encoder.close();

      // 3. Share atau Beritahu User
      // Di Android/iOS, cara termudah "mendownload" adalah memicu Share Sheet
      await Share.shareXFiles([XFile(zipPath)], text: 'Download Catatan: $title');
      
    } catch (e) {
      print("Error creating ZIP: $e");
    }
  }
}