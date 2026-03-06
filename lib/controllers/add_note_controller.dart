import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddNoteController extends GetxController {
  // Variabel reaktif untuk path gambar
  var selectedImagePath = ''.obs;

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  // Fungsi untuk menghapus gambar jika user batal
  void removeImage() {
    selectedImagePath.value = '';
  }
}