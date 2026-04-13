import 'package:cozbak/features/analysis/service/cloudinary_upload_service.dart';
import 'package:cozbak/features/analysis/service/question_analysis_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cloudinaryUploadServiceProvider = Provider<CloudinaryUploadService>((ref) {
  return CloudinaryUploadService(
    cloudName: 'dh62nt45i',
    uploadPreset: 'cozbak_unsigned',
  );
});

final questionAnalysisApiServiceProvider =
    Provider<QuestionAnalysisApiService>((ref) {
  return QuestionAnalysisApiService();
});