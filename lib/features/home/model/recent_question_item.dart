import 'package:cloud_firestore/cloud_firestore.dart';

class RecentQuestionItem {
  final String id;
  final String? imageUrl;
  final String lesson;
  final String category;
  final String recognizedQuestion;
  final String finalAnswer;
  final String status;
  final DateTime? createdAt;

  const RecentQuestionItem({
    required this.id,
    required this.imageUrl,
    required this.lesson,
    required this.category,
    required this.recognizedQuestion,
    required this.finalAnswer,
    required this.status,
    required this.createdAt,
  });

  factory RecentQuestionItem.fromMap(String id, Map<String, dynamic> map) {
    final createdAtTs = map['createdAt'];

    return RecentQuestionItem(
      id: id,
      imageUrl: map['imageUrl'] as String?,
      lesson: (map['lesson'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      recognizedQuestion: (map['recognizedQuestion'] as String?) ?? '',
      finalAnswer: (map['finalAnswer'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'processing',
      createdAt: createdAtTs is Timestamp ? createdAtTs.toDate() : null,
    );
  }
}