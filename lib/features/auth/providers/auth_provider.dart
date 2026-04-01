import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authServiceProvider).authStateChanges(),
);