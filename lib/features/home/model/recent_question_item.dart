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
  final DateTime? updatedAt;

  const RecentQuestionItem({
    required this.id,
    required this.imageUrl,
    required this.lesson,
    required this.category,
    required this.recognizedQuestion,
    required this.finalAnswer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentQuestionItem.fromMap(String id, Map<String, dynamic> map) {
    final createdAtTs = map['createdAt'];

    final recognizedQuestion =
        (map['recognizedQuestion'] as String?)?.trim();

    final lesson = (map['lesson'] as String?) ?? '';
    
    final category = (map['category'] as String?) ?? '';
    final finalAnswer = (map['finalAnswer'] as String?) ?? '';
    final updatedAtTs = map['updatedAt'];

    return RecentQuestionItem(
      id: id,
      imageUrl: map['imageUrl'] as String?,
      lesson: lesson,
      category: category,
      
      recognizedQuestion:
          recognizedQuestion != null && recognizedQuestion.isNotEmpty
              ? recognizedQuestion
              : '$lesson • $category',
      finalAnswer: finalAnswer,
      status: (map['status'] as String?) ?? 'processing',
      createdAt: createdAtTs is Timestamp ? createdAtTs.toDate() : null,
      updatedAt: updatedAtTs is Timestamp ? updatedAtTs.toDate() : null,
    );
  }
}