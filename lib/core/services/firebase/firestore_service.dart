import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cozbak/features/home/model/recent_question_item.dart';
import 'package:cozbak/shared/model/app_user.dart';
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

Stream<AppUser?> watchUser(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return AppUser.fromMap(doc.id, data);
  });
}

Stream<List<RecentQuestionItem>> watchRecentQuestions(String uid) {
  return FirebaseFirestore.instance
      .collection('questions')
      .where('userId', isEqualTo: uid)
      .where('status', isEqualTo: 'completed')
      .orderBy('updatedAt', descending: true)
      .limit(2)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => RecentQuestionItem.fromMap(doc.id, doc.data()))
            .toList(),
      );
}


}