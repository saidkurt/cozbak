import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/auth_provider.dart';
import 'package:cozbak/features/home/model/recent_question_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questionHistoryProvider =
    StreamProvider<List<RecentQuestionItem>>((ref) {
  final authUser = ref.watch(authStateProvider).valueOrNull;

  if (authUser == null) {
    return Stream.value(const []);
  }

  return ref
      .watch(firestoreServiceProvider)
      .watchQuestionHistory(authUser.uid);
});