import 'package:cozbak/features/analysis/provider/current_question_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AnalysisStage {
  uploading,
  processing,
  completed,
  failed,
}

final analysisStageProvider = Provider<AnalysisStage>((ref) {
  final questionAsync = ref.watch(currentQuestionProvider);

  return questionAsync.maybeWhen(
    data: (question) {
      final status = question?.status ?? 'uploading';

      switch (status) {
        case 'uploading':
          return AnalysisStage.uploading;
        case 'processing':
          return AnalysisStage.processing;
        case 'completed':
          return AnalysisStage.completed;
        case 'failed':
          return AnalysisStage.failed;
        default:
          return AnalysisStage.processing;
      }
    },
    orElse: () => AnalysisStage.processing,
  );
});