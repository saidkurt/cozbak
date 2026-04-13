import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService(this._picker);

  final ImagePicker _picker;

  Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (picked == null) return null;
    return File(picked.path);
  }
}