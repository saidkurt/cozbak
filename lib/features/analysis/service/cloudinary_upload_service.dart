import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryUploadService {
  CloudinaryUploadService({
    required this.cloudName,
    required this.uploadPreset,
  });

  final String cloudName;
  final String uploadPreset;

  Future<String> uploadQuestionImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'cozbak/questions'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload başarısız: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final imageUrl = data['secure_url']?.toString();

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Cloudinary image url alınamadı.');
    }

    return imageUrl;
  }
}