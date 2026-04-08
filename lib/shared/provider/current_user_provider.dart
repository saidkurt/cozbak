import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/auth_provider.dart';
import 'package:cozbak/shared/model/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    return Stream.value(null);
  }

  return ref.read(firestoreServiceProvider).watchUser(authUser.uid);
});