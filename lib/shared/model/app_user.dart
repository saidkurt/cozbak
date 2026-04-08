import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final int credits;
  final int freeAnalysesUsed;
  final int purchasedCredits;
  final int rewardedAdsWatched;
  final int totalAnalyses;
  final bool isPremium;
  final bool isAdFree;
  final bool onboardingCompleted;
  final String? preferredLanguage;
  final String? provider;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.credits,
    required this.freeAnalysesUsed,
    required this.purchasedCredits,
    required this.rewardedAdsWatched,
    required this.totalAnalyses,
    required this.isPremium,
    required this.isAdFree,
    required this.onboardingCompleted,
    required this.preferredLanguage,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
  });


  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
  final createdAtTs = map['createdAt'];
  final lastLoginAtTs = map['lastLoginAt'];

  return AppUser(
    uid: uid,
    name: map['name'] as String?,
    email: map['email'] as String?,
    photoUrl: map['photoUrl'] as String?,
    credits: (map['credits'] as num?)?.toInt() ?? 0,
    freeAnalysesUsed: (map['freeAnalysesUsed'] as num?)?.toInt() ?? 0,
    purchasedCredits: (map['purchasedCredits'] as num?)?.toInt() ?? 0,
    rewardedAdsWatched: (map['rewardedAdsWatched'] as num?)?.toInt() ?? 0,
    totalAnalyses: (map['totalAnalyses'] as num?)?.toInt() ?? 0,
    isPremium: map['isPremium'] as bool? ?? false,
    isAdFree: map['isAdFree'] as bool? ?? false,
    onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
    preferredLanguage: map['preferredLanguage'] as String?,
    provider: map['provider'] as String?,
    createdAt: createdAtTs is Timestamp ? createdAtTs.toDate() : null,
    lastLoginAt: lastLoginAtTs is Timestamp ? lastLoginAtTs.toDate() : null,
  );
}
}