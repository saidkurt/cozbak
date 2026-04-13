import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class QuestionAnalysisApiService {
  QuestionAnalysisApiService();

  Future<void> startAnalysis({
    required String questionId,
    required String imageUrl,
  }) async {
    const endpoint =
        'https://us-central1-cozbak-e7a9a.cloudfunctions.net/helloWorld';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturumu bulunamadı.');
    }

    final idToken = await user.getIdToken(true);

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'questionId': questionId,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Analiz başlatılamadı: ${response.statusCode} ${response.body}',
      );
    }
  }
}