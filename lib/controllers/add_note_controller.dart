import 'package:flutter/material.dart'; // WAJIB ADA untuk TextEditingController
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';

class AddNoteController extends GetxController {
  // --- TAMBAHKAN DUA BARIS INI ---
  int? currentId;
  final titleController = TextEditingController();
  final noteController = TextEditingController();

  var selectedImagePath = ''.obs;
  var searchText = ''.obs;

  // Fungsi ambil gambar
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  void setSearchText(String text) {
    searchText.value = text;
  }

  // Fungsi simpan ke database
  void saveNoteToDB() async {
    if (titleController.text.isEmpty || noteController.text.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Judul dan isi tidak boleh kosong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String fullDateTime = DateFormat(
      'dd MMMM yyyy, hh:mm a',
    ).format(DateTime.now());

    Map<String, dynamic> noteData = {
      'title': titleController.text,
      'note': noteController.text,
      'date': fullDateTime,
      'imagePath': selectedImagePath.value,
    };

    if (currentId == null) {
      await DBHelper.insert(noteData);
    } else {
      // Pastikan DBHelper punya fungsi update
      await DBHelper.update(currentId!, noteData); 
    }

  @override
  void onClose() {
    // Bersihkan controller saat halaman ditutup agar hemat memori
    titleController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
}