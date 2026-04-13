class QuestionStepModel {
  const QuestionStepModel({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    required this.result,
  });

  final int stepNumber;
  final String title;
  final String explanation;
  final String result;

  factory QuestionStepModel.fromMap(Map<String, dynamic> map) {
    return QuestionStepModel(
      stepNumber: (map['stepNumber'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? '').toString(),
      explanation: (map['explanation'] ?? '').toString(),
      result: (map['result'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'explanation': explanation,
      'result': result,
    };
  }
}

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.creditCharged,
    this.category,
    this.createdAt,
    this.errorMessage,
    this.finalAnswer,
    this.generalMethod,
    this.imageUrl,
    this.lesson,
    this.recognizedQuestion,
    this.commonMistake,
    this.tips,
    this.similarQuestion,
    this.steps = const [],
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String status;
  final bool creditCharged;

  final String? category;
  final DateTime? createdAt;
  final String? errorMessage;
  final String? finalAnswer;
  final String? generalMethod;
  final String? imageUrl;
  final String? lesson;
  final String? recognizedQuestion;
  final String? commonMistake;
  final String? tips;
  final String? similarQuestion;
  final List<QuestionStepModel> steps;
  final DateTime? updatedAt;

  factory QuestionModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return value.toDate();
      } catch (_) {
        return null;
      }
    }

    final rawSteps = map['steps'];
    final steps = rawSteps is List
        ? rawSteps
            .map((e) => QuestionStepModel.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <QuestionStepModel>[];

    return QuestionModel(
      id: id,
      userId: (map['userId'] ?? '').toString(),
      status: (map['status'] ?? 'uploading').toString(),
      creditCharged: map['creditCharged'] == true,
      category: map['category']?.toString(),
      createdAt: parseDate(map['createdAt']),
      errorMessage: map['errorMessage']?.toString(),
      finalAnswer: map['finalAnswer']?.toString(),
      generalMethod: map['generalMethod']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      lesson: map['lesson']?.toString(),
      recognizedQuestion: map['recognizedQuestion']?.toString(),
      commonMistake: map['commonMistake']?.toString(),
      tips: map['tips']?.toString(),
      similarQuestion: map['similarQuestion']?.toString(),
      steps: steps,
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}