import 'package:cozbak/core/services/media/image_picker_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ImagePicker());
});