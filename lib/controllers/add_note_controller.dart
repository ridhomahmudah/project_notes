import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';
import '../models/note_model.dart';

class AddNoteController extends GetxController {
  final titleController = TextEditingController();
  final noteController = TextEditingController();

  var selectedImagePath = ''.obs;
  var searchText = ''.obs;
  var selectedCategory = 'Semua'.obs;
  var allNotes = <NoteModel>[].obs;
  var selectedColor = 0.obs;
  var attachedNotes =
      <Map<String, dynamic>>[]
          .obs; // List untuk menyimpan catatan yang disisipkan

  @override
  void onInit() {
    super.onInit();
    fetchAllNotes();
  }

  void attachNote(Map<String, dynamic> note) {
    // Cek apakah sudah ada agar tidak duplikat
    if (!attachedNotes.any((element) => element['id'] == note['id'])) {
      attachedNotes.add(note);
    }
  }

  void removeAttachedNote(int id) {
    attachedNotes.removeWhere((element) => element['id'] == id);
  }

  // --- FITUR SISIPKAN CATATAN (LOGIC) ---
  void insertExistingNote(NoteModel selectedNote) {
    // Format teks yang akan disisipkan
    String textToInsert =
        "\n\n--- Referensi Catatan ---\n"
        "Judul: ${selectedNote.title}\n"
        "Isi: ${selectedNote.note}\n"
        "-------------------------\n";

    // Gabungkan ke noteController yang sedang aktif
    noteController.text = noteController.text + textToInsert;

    // Pindahkan kursor teks ke paling akhir agar user bisa lanjut mengetik
    noteController.selection = TextSelection.fromPosition(
      TextPosition(offset: noteController.text.length),
    );
  }

  void updateColor(int colorValue) {
    selectedColor.value = colorValue;
  }

  void fetchAllNotes() async {
    try {
      List<Map<String, dynamic>> notes = await DBHelper.query();
      allNotes.assignAll(
        notes.map((data) => NoteModel.fromJson(data)).toList(),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  void saveNoteToDB() async {
    // 1. Validasi Input
    if (titleController.text.trim().isEmpty ||
        noteController.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Judul dan isi tidak boleh kosong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return;
    }

    // 2. Format Waktu
    String fullDateTime = DateFormat(
      'dd MMMM yyyy, hh:mm a',
    ).format(DateTime.now());

    // 3. Gabungkan Konten Utama dengan Info Lampiran untuk teks visual
    String finalContent = noteController.text;
    if (attachedNotes.isNotEmpty) {
      finalContent += "\n\n--- Referensi Lampiran ---";
      for (var attached in attachedNotes) {
        finalContent += "\n📌 ${attached['title'] ?? 'Tanpa Judul'}";
      }
    }

    // 4. Proses ID lampiran menjadi String untuk disimpan di kolom attachedIds
    String? attachedIdsString =
        attachedNotes.isEmpty
            ? null
            : attachedNotes.map((e) => e['id'].toString()).join(',');

    // 5. Buat Object Model sesuai struktur class NoteModel terbaru
    NoteModel newNote = NoteModel(
      title: titleController.text,
      note: finalContent,
      date: fullDateTime,
      imagePath: selectedImagePath.value,
      color: selectedColor.value, // Mengambil nilai dari obs selectedColor
      category: selectedCategory.value,
      attachedIds: attachedIdsString, // Menyimpan ID relasi
    );

    // 6. Eksekusi Simpan ke Database
    try {
      await DBHelper.insert(newNote.toJson());

      // 7. Reset State & Tutup Halaman
      _resetForm(); // Pastikan fungsi ini membersihkan title, note, imagePath, dan attachedNotes

      Get.back(); // Kembali ke halaman utama
      Get.snackbar(
        "Sukses",
        "Catatan berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    } catch (e) {
      print("Error saving to DB: $e");
      Get.snackbar(
        "Error",
        "Gagal menyimpan catatan ke database. Pastikan tabel sudah di-update.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    }
  }

  // Fungsi pembantu untuk membersihkan form
  void _resetForm() {
    titleController.clear();
    noteController.clear();
    selectedImagePath.value = '';
    selectedColor.value = 0; // Reset warna ke default
    attachedNotes.clear();
  }

  @override
  void onClose() {
    titleController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
