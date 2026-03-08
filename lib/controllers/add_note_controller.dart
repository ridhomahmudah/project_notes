import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';
import '../models/note_model.dart';
import '../views/image_editor_view.dart';

class AddNoteController extends GetxController {
  // --- Properti Utama ---
  int? currentId; // Untuk membedakan mode Simpan Baru atau Update
  final titleController = TextEditingController();
  final noteController = TextEditingController();

  // --- Observables (State Management) ---
  var selectedImagePath = ''.obs;
  var searchText = ''.obs;
  var selectedCategory = 'Semua'.obs;
  var selectedColor = 0.obs;
  var allNotes = <NoteModel>[].obs; // Koleksi semua catatan untuk fitur referensi
  var attachedNotes = <Map<String, dynamic>>[].obs; // List lampiran sementara

  @override
  void onInit() {
    super.onInit();
    fetchAllNotes(); // Muat referensi saat controller aktif
  }

  // --- Fungsi Database & Data ---
  void fetchAllNotes() async {
    try {
      List<Map<String, dynamic>> notes = await DBHelper.query();
      allNotes.assignAll(
        notes.map((data) => NoteModel.fromJson(data)).toList(),
      );
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }
  }

  // Fungsi ambil gambar dari galeri
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  void updateColor(int colorValue) {
    selectedColor.value = colorValue;
  }

  // Navigasi ke Image Editor
  void goToImageEditor() async {
    if (selectedImagePath.value.isEmpty) {
      Get.snackbar("Info", "Pilih gambar terlebih dahulu");
      return;
    }
    final editedPath = await Get.to(
      () => ImageEditorView(imagePath: selectedImagePath.value),
    );
    if (editedPath != null) {
      selectedImagePath.value = editedPath;
    }
  }

  // --- Fitur Lampiran (Attachment) ---
  void attachNote(Map<String, dynamic> note) {
    if (!attachedNotes.any((element) => element['id'] == note['id'])) {
      attachedNotes.add(note);
    }
  }

  void removeAttachedNote(int id) {
    attachedNotes.removeWhere((element) => element['id'] == id);
  }

  // --- Fungsi Simpan Utama ---
  void saveNoteToDB() async {
    // 1. Validasi Input
    if (titleController.text.trim().isEmpty || noteController.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan", "Judul dan isi tidak boleh kosong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return;
    }

    // 2. Format Waktu
    String fullDateTime = DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now());

    // 3. Olah ID lampiran menjadi String (CSV) untuk DB
    String? attachedIdsString = attachedNotes.isEmpty
        ? null
        : attachedNotes.map((e) => e['id'].toString()).join(',');

    // 4. Siapkan Map data sesuai skema DBHelper v3
    Map<String, dynamic> noteData = {
      'title': titleController.text,
      'note': noteController.text,
      'date': fullDateTime,
      'imagePath': selectedImagePath.value,
      'color': selectedColor.value,
      'category': selectedCategory.value,
      'attachedIds': attachedIdsString,
    };

    try {
      if (currentId == null) {
        // Mode: Tambah Baru
        await DBHelper.insert(noteData);
      } else {
        // Mode: Update/Edit
        noteData['id'] = currentId; // Pastikan ID disertakan untuk update
        await DBHelper.update(noteData);
      }

      _resetForm();
      Get.back(); // Kembali ke halaman Home
      Get.snackbar("Sukses", "Catatan berhasil disimpan", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint("Error saving to DB: $e");
      Get.snackbar("Error", "Gagal menyimpan. Cek struktur Database.");
    }
  }

  void _resetForm() {
    titleController.clear();
    noteController.clear();
    selectedImagePath.value = '';
    selectedColor.value = 0;
    attachedNotes.clear();
    currentId = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    noteController.dispose();
    super.onClose();
  }
}