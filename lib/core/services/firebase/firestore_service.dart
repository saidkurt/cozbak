import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

Future<void> createOrUpdateUser(User user) async {
  final doc = _firestore.collection('users').doc(user.uid);

  final existing = await doc.get();

  if (!existing.exists) {
    await doc.set({
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'credits': 5,
      'freeAnalysesUsed': 0,
      'isPremium': false,
      'isAdFree': false,
      'provider': user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'email',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'totalAnalyses': 0,
      'rewardedAdsWatched': 0,
      'purchasedCredits': 0,
      'preferredLanguage': 'tr',
      'onboardingCompleted': true,
    });
  } else {
    await doc.update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'name': user.displayName ?? existing.data()?['name'],
      'photoUrl': user.photoURL ?? existing.data()?['photoUrl'],
    });
  }
}
}