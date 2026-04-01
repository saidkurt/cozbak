import 'package:cozbak/core/services/firebase/firebase_auth_service.dart';
import 'package:cozbak/core/services/firebase/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(ref.read(firebaseAuthProvider)),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
