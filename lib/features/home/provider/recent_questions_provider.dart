import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/auth_provider.dart';
import 'package:cozbak/features/home/model/recent_question_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recentQuestionsProvider =
    StreamProvider<List<RecentQuestionItem>>((ref) {
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    return Stream.value(const []);
  }

  return ref.read(firestoreServiceProvider).watchRecentQuestions(authUser.uid);
});

final rewardedLoadingProvider = StateProvider<bool>((ref) => false);