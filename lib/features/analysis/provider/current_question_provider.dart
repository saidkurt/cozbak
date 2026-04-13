import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/analysis/provider/current_question_id_provider.dart';
import 'package:cozbak/shared/model/question_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentQuestionProvider =
    StreamProvider.autoDispose<QuestionModel?>((ref) {
  final questionId = ref.watch(currentQuestionIdProvider);

  if (questionId == null || questionId.isEmpty) {
    return const Stream<QuestionModel?>.empty();
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.watchQuestion(questionId);
});