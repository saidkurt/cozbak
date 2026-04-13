import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/core/services/media/media_providers.dart';
import 'package:cozbak/features/analysis/provider/analysis_image_provider.dart';
import 'package:cozbak/features/analysis/provider/current_question_id_provider.dart';
import 'package:cozbak/features/analysis/service/analysis_service_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final analysisSubmitProvider =
    AsyncNotifierProvider<AnalysisSubmitNotifier, void>(
  AnalysisSubmitNotifier.new,
);

class AnalysisSubmitNotifier extends AsyncNotifier<void> {
  bool _started = false;

  @override
  Future<void> build() async {}

  Future<bool> pickFromCamera() async {
    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickFromCamera();

    if (file == null) return false;

    final questionId = const Uuid().v4();

    ref.read(analysisImageProvider.notifier).state = file;
    ref.read(currentQuestionIdProvider.notifier).state = questionId;

    _started = false;
    state = const AsyncData(null);
    return true;
  }

  Future<bool> pickFromGallery() async {
    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickFromGallery();

    if (file == null) return false;

    final questionId = const Uuid().v4();

    ref.read(analysisImageProvider.notifier).state = file;
    ref.read(currentQuestionIdProvider.notifier).state = questionId;

    _started = false;
    state = const AsyncData(null);
    return true;
  }

  Future<void> startAnalysis() async {
    if (_started) return;

    final file = ref.read(analysisImageProvider);
    final questionId = ref.read(currentQuestionIdProvider);

    if (file == null || questionId == null || questionId.isEmpty) {
      throw Exception('Analiz için gerekli veriler bulunamadı.');
    }

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      throw Exception('Kullanıcı oturumu bulunamadı.');
    }

    _started = true;
    state = const AsyncLoading();

    final firestoreService = ref.read(firestoreServiceProvider);
    final cloudinaryService = ref.read(cloudinaryUploadServiceProvider);
    final apiService = ref.read(questionAnalysisApiServiceProvider);

    try {
      await firestoreService.createUploadingQuestion(
        questionId: questionId,
        userId: authUser.uid,
      );

      final imageUrl = await cloudinaryService.uploadQuestionImage(file);

      await firestoreService.updateQuestionUploadInfo(
        questionId: questionId,
        imageUrl: imageUrl,
      );

      await apiService.startAnalysis(
        questionId: questionId,
        imageUrl: imageUrl,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      _started = false;

      await firestoreService.markQuestionFailed(
        questionId: questionId,
        errorMessage: e.toString(),
      );

      state = AsyncError(e, st);
    }
  }

  void clearSession() {
    ref.read(analysisImageProvider.notifier).state = null;
    ref.read(currentQuestionIdProvider.notifier).state = null;
    _started = false;
    state = const AsyncData(null);
  }
}